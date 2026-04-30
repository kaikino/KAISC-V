// ALU for RV64I

module alu #(parameter WIDTH = 64) (
  input  logic [WIDTH-1:0] a,
  input  logic [WIDTH-1:0] b,
  input  logic [3:0]       alu_ctrl,   // {funct7[5], funct3}
  output logic [WIDTH-1:0] result,
  output logic             zero
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
  logic overflow;
  not n2   (nc2, alu_ctrl[2]);
  and aslt (is_slt, nc2, alu_ctrl[1]);
  or  osub (sub, alu_ctrl[3], is_slt);
  mux #(.WIDTH(WIDTH), .DEPTH(2)) mb (.in({nb, b}), .sel(sub), .out(b_in));
  adder64 adder (.a(a), .b(b_in), .cin(sub), .sum(add_result), .cout(add_cout), .overflow);

  // shifts: funct3[2] distinguishes SLL (001) vs SR* (101); funct7[5] => SRA vs SRL
  logic [WIDTH-1:0] shift_result;
  shifter64 barrel (.in(a), .shamt(b[5:0]), .dir_right(alu_ctrl[2]),
                    .arith(alu_ctrl[3]), .out(shift_result));

  // set less than
  logic slt_bit, sltu_bit;
  xor slt_xor  (slt_bit, add_result[WIDTH-1], overflow);
  not sltu_not (sltu_bit, add_cout);
  logic [WIDTH-1:0] slt_result, sltu_result;
  assign slt_result  = {{(WIDTH-1){1'b0}}, slt_bit};
  assign sltu_result = {{(WIDTH-1){1'b0}}, sltu_bit};

  // result mux
  // 000=ADD/SUB  001=SLL  010=SLT   011=SLTU
  // 100=XOR      101=SR   110=OR    111=AND
  mux #(.WIDTH(WIDTH), .DEPTH(8)) result_mux (
    .in ({and_result, or_result, shift_result, xor_result,
          sltu_result, slt_result, shift_result, add_result}),
    .sel(alu_ctrl[2:0]), .out(result));

  zero64 zd (.in(result), .out(zero));  // zero flag

endmodule  // alu
