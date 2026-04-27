// RV64I control unit

module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    input  logic       alu_zero,
    input  logic       alu_lt,

    output logic       reg_write,
    output logic       mem_read,
    output logic       mem_write,
    output logic [1:0] mem_to_reg,
    output logic       alu_src,
    output logic       branch,
    output logic       jump,
    output logic [3:0] alu_op,
    output logic [2:0] imm_sel,
    output logic       word32,
    output logic       pc_src
);

    // Decode opcode to one-hot (index equals opcode value)
    logic [127:0] op_hot;
    dec #(.DEPTH(128)) dec_op (.in(opcode), .enable(1'b1), .out(op_hot));

    // Instruction-class taps from opcode one-hot bus
    logic is_load, is_store, is_branch, is_jalr, is_jal, is_lui, is_auipc;
    logic is_imm, is_reg, is_imm32, is_reg32;
    assign is_load   = op_hot[7'b0000011];
    assign is_store  = op_hot[7'b0100011];
    assign is_branch = op_hot[7'b1100011];
    assign is_jalr   = op_hot[7'b1100111];
    assign is_jal    = op_hot[7'b1101111];
    assign is_lui    = op_hot[7'b0110111];
    assign is_auipc  = op_hot[7'b0010111];
    assign is_imm    = op_hot[7'b0010011];
    assign is_reg    = op_hot[7'b0110011];
    assign is_imm32  = op_hot[7'b0011011];
    assign is_reg32  = op_hot[7'b0111011];

    // Grouped class flags used by later decode
    logic do_alu;
    or o_dalu (do_alu, is_reg, is_imm, is_reg32, is_imm32);

    // Decode funct3 only when needed (ALU or branch instructions)
    logic [7:0] f3_hot;
    logic       decf3_en;
    or o_f3en (decf3_en, do_alu, is_branch);
    dec #(.DEPTH(8)) decf3 (.in(funct3), .enable(decf3_en), .out(f3_hot));

    logic or1, or2;
    or o_rw1 (or1, is_load, is_jalr, is_jal, is_lui);
    or o_rw2 (or2, is_auipc, is_imm, is_reg, is_imm32);
    or o_rw3 (reg_write, or1, or2, is_reg32);

    assign mem_read  = is_load;
    assign mem_write = is_store;

    logic alu_src0;
    or o_as1 (alu_src0, is_load, is_store, is_jalr, is_lui);
    or o_as2 (alu_src, alu_src0, is_auipc, is_imm, is_imm32);

    assign branch = is_branch;
    or o_jump (jump, is_jal, is_jalr);
    or o_w32 (word32, is_imm32, is_reg32);

    or o_mtr (mem_to_reg[0], is_jal, is_jalr);
    assign mem_to_reg[1] = is_load;

    // Immediate-format select
    // Encodings: I=000, S=001, B=010, U=011, J=100
    // Selector bits are {is_jal, (is_lui|is_auipc), (is_store|is_branch)}
    logic lui_or_auipc, st_or_br;
    or o_luiau (lui_or_auipc, is_lui, is_auipc);
    or o_stbr (st_or_br, is_store, is_branch);

    mux #(.WIDTH(3), .DEPTH(8)) mux_imm (
      .in({3'b000, 3'b011, 3'b000, 3'b100, 3'b000, 3'b010, 3'b001, 3'b000}),
      .sel({is_jal, lui_or_auipc, st_or_br}),
      .out(imm_sel)
    );

    // ALU operation select (`alu_op`) in ALU-native encoding: {funct7[5], funct3}
    // Detect immediate-shift forms where funct7[5] is meaningful
    logic f2, f1, f0, nf2, nf1;
    assign f2 = funct3[2];
    assign f1 = funct3[1];
    assign f0 = funct3[0];
    not n_f2 (nf2, f2);
    not n_f1 (nf1, f1);
    logic is_slli, is_srxi, imm_sh;
    and a_slli (is_slli, nf2, nf1, f0);
    and a_srxi (is_srxi, f2, nf1, f0);
    or o_imsh (imm_sh, is_slli, is_srxi);

    // `alu_op[3]` source:
    // - R/RW instructions: use funct7[5]
    // - I/IW instructions: use funct7[5] only for SLLI/SRLI/SRAI
    // - all others: 0
    logic reg_or_r32, imm_or_i32, alt_t1, alt_t2, altb;
    or o_rr32 (reg_or_r32, is_reg, is_reg32);
    or o_ii32 (imm_or_i32, is_imm, is_imm32);
    and a_alt1 (alt_t1, funct7[5], reg_or_r32);
    logic imm_sh_i;
    and a_imshi (imm_sh_i, imm_sh, imm_or_i32);
    and a_alt2 (alt_t2, funct7[5], imm_sh_i);
    or o_altb (altb, alt_t1, alt_t2);

    logic [3:0] alu_ri;
    assign alu_ri[3]   = altb;
    assign alu_ri[2:0] = funct3;

    // Branch compare operation map (selected by funct3[2:1]):
    // 00 -> SUB  (BEQ/BNE), 01 -> reserved(ADD)
    // 10 -> SLT  (BLT/BGE), 11 -> SLTU (BLTU/BGEU)
    logic [3:0] alu_br;
    mux #(.WIDTH(4), .DEPTH(4)) u_br_alu (
        .in  ({4'b0011, 4'b0010, 4'b0000, 4'b1000}),
        .sel (funct3[2:1]),
        .out (alu_br)
    );

    // Final ALU op selection:
    // sel={do_alu,is_branch}:
    //   00 -> ADD (address/calc default), 01 -> branch compare op
    //   1x -> register/immediate ALU op
    logic [3:0]        alu_add0;
    logic [3:0][3:0]   alu_op_in;
    logic [1:0]        alu_op_sel;
    assign alu_add0 = 4'b0000;
    assign alu_op_in[0] = alu_add0;
    assign alu_op_in[1] = alu_br;
    assign alu_op_in[2] = alu_ri;
    assign alu_op_in[3] = alu_ri;
    assign alu_op_sel   = {do_alu, is_branch};

    mux #(.WIDTH(4), .DEPTH(4), .SEL(2)) mux_alu_op (.in(alu_op_in), .sel(alu_op_sel), .out(alu_op));

    // Next-PC control
    // Per-branch condition result by funct3:
    // BEQ, BNE, BLT, BGE, BLTU, BGEU (reserved funct3 values map to 0)
    logic n_alu_zero, n_alu_lt;
    not n_az (n_alu_zero, alu_zero);
    not n_lt (n_alu_lt, alu_lt);

    logic any_taken;
    mux #(.WIDTH(1), .DEPTH(8)) u_br_flag (
      .in({n_alu_lt, alu_lt, n_alu_lt, alu_lt, 1'b0, 1'b0, n_alu_zero, alu_zero}),
      .sel(funct3),
      .out(any_taken)
    );

    logic branch_taken, pc_j;
    and a_brt (branch_taken, is_branch, any_taken);
    or  o_pcs (pc_src, branch_taken, is_jal, is_jalr);

endmodule
