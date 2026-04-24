// ALU for RV64I

module alu #(parameter WIDTH = 64) (
  input  logic [WIDTH-1:0] a,
  input  logic [WIDTH-1:0] b,
  input  logic [3:0]       alu_ctrl,   // {funct7[5], funct3}
  output logic [WIDTH-1:0] result,
  output logic             zero,
  output logic             negative,
  output logic             overflow,
  output logic             carry_out
);

  // bitwise ops
  logic [WIDTH-1:0] and_result, or_result, xor_result, nb;
  genvar i;
  generate
    for (i = 0; i < WIDTH; i++) begin : bitwiseOps
      and ag (and_result[i], a[i], b[i]);
      or  og (or_result[i],  a[i], b[i]);
      xor xg (xor_result[i], a[i], b[i]);
      not ng (nb[i], b[i]);
    end
  endgenerate

  // adder
  logic [WIDTH-1:0] b_in;
  logic [WIDTH-1:0] add_result;
  logic             add_cout;
  // sub if SUB, SLT, SLTU
  logic sub, is_slt, nc2;
  not n2   (nc2, alu_ctrl[2]);
  and aslt (is_slt, nc2, alu_ctrl[1]);
  or  osub (sub, alu_ctrl[3], is_slt);
  mux #(.WIDTH(WIDTH), .DEPTH(2)) mb (.in({nb, b}), .sel(sub), .out(b_in));
  adder64 adder (.a(a), .b(b_in), .cin(sub), .sum(add_result), .cout(add_cout), .overflow);

  // shifts
  logic [WIDTH-1:0] sll_result, srl_result, sra_result, shift_right_result;
  lshift64 sll (.in(a), .shamt(b[5:0]), .out(sll_result));
  rshift64 srl (.in(a), .shamt(b[5:0]), .arithmetic(1'b0), .out(srl_result));
  rshift64 sra (.in(a), .shamt(b[5:0]), .arithmetic(1'b1), .out(sra_result));
  mux #(.WIDTH(WIDTH), .DEPTH(2)) ms (.in ({sra_result, srl_result}), .sel(alu_ctrl[3]), .out(shift_right_result));

  // set less than
  logic slt_bit, sltu_bit, n_carry_out;
  xor slt_xor  (slt_bit, add_result[WIDTH-1], overflow);
  not sltu_not (sltu_bit, add_cout);
  logic [WIDTH-1:0] slt_result, sltu_result;
  assign slt_result  = {{(WIDTH-1){1'b0}}, slt_bit};
  assign sltu_result = {{(WIDTH-1){1'b0}}, sltu_bit};

  // result mux
  // 000=ADD/SUB  001=SLL  010=SLT   011=SLTU
  // 100=XOR      101=SR   110=OR    111=AND
  mux #(.WIDTH(WIDTH), .DEPTH(8)) result_mux (
    .in ({and_result, or_result, shift_right_result, xor_result,
          sltu_result, slt_result, sll_result, add_result}),
    .sel(alu_ctrl[2:0]), .out(result));

  assign carry_out = add_cout;          // carry flag
  assign negative = result[WIDTH-1];    // negative flag
  zero64 zd (.in(result), .out(zero));  // zero flag

endmodule  // alu
