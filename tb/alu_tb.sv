// Testbench for alu

`timescale 1ns/10ps

module alu_tb ();

  parameter DELAY = 200000;

  logic [63:0] a, b;
  logic [3:0]  alu_ctrl;
  logic [63:0] result;
  logic        negative, zero, overflow, carry_out;

  parameter ALU_ADD  = 4'b0000;
  parameter ALU_SUB  = 4'b1000;
  parameter ALU_SLL  = 4'b0001;
  parameter ALU_SLT  = 4'b0010;
  parameter ALU_SLTU = 4'b0011;
  parameter ALU_XOR  = 4'b0100;
  parameter ALU_SRL  = 4'b0101;
  parameter ALU_SRA  = 4'b1101;
  parameter ALU_OR   = 4'b0110;
  parameter ALU_AND  = 4'b0111;

  alu dut (.a, .b, .alu_ctrl, .result, .negative, .zero, .overflow, .carry_out);

  integer i;

  task check_result(input [63:0] expected);
    assert(result   == expected)         else $error("result:   got %h expected %h", result,   expected);
    assert(negative == expected[63])     else $error("negative: got %b expected %b", negative, expected[63]);
    assert(zero     == (expected == '0)) else $error("zero:     got %b expected %b", zero,     (expected == '0));
  endtask

  task check_flags(
    input exp_overflow,
    input exp_negative,
    input exp_carry_out,
    input exp_zero
  );
    assert(overflow  == exp_overflow)  else $error("overflow:  got %b expected %b", overflow,  exp_overflow);
    assert(negative  == exp_negative)  else $error("negative:  got %b expected %b", negative,  exp_negative);
    assert(carry_out == exp_carry_out) else $error("carry_out: got %b expected %b", carry_out, exp_carry_out);
    assert(zero      == exp_zero)      else $error("zero:      got %b expected %b", zero,      exp_zero);
  endtask

  initial begin
    $display("=== RV64I ALU testbench ===");

    // ── ADD ────────────────────────────────────────────────────────────────
    $display("Testing ADD...");
    alu_ctrl = ALU_ADD;
    for (i = 0; i < 10; i++) begin
      a = {$random(), $random()};
      b = {$random(), $random()};
      #(DELAY);
      check_result(a + b);
    end
    // pos + pos = neg (overflow)
    a = 64'h7FFFFFFFFFFFFFFF; b = 64'h0000000000000001;
    #(DELAY);
    check_flags(1, 1, 0, 0);
    // neg + neg = pos (overflow)
    a = 64'h8000000000000000; b = 64'h8000000000000000;
    #(DELAY);
    check_flags(1, 0, 1, 1);
    // zero + zero
    a = 64'h0; b = 64'h0;
    #(DELAY);
    check_flags(0, 0, 0, 1);

    // ── SUB ────────────────────────────────────────────────────────────────
    $display("Testing SUB...");
    alu_ctrl = ALU_SUB;
    for (i = 0; i < 10; i++) begin
      a = {$random(), $random()};
      b = {$random(), $random()};
      #(DELAY);
      check_result(a - b);
    end
    // pos - neg = neg (overflow)
    a = 64'h7FFFFFFFFFFFFFFF; b = 64'h8000000000000000;
    #(DELAY);
    check_flags(1, 1, 0, 0);
    // neg - pos = pos (overflow)
    a = 64'h8000000000000000; b = 64'h0000000000000001;
    #(DELAY);
    check_flags(1, 0, 1, 0);
    // a == b → zero, carry_out=1
    a = 64'hDEADBEEFDEADBEEF; b = 64'hDEADBEEFDEADBEEF;
    #(DELAY);
    check_flags(0, 0, 1, 1);

    // ── AND ────────────────────────────────────────────────────────────────
    $display("Testing AND...");
    alu_ctrl = ALU_AND;
    for (i = 0; i < 10; i++) begin
      a = {$random(), $random()};
      b = {$random(), $random()};
      #(DELAY);
      check_result(a & b);
    end

    // ── OR ─────────────────────────────────────────────────────────────────
    $display("Testing OR...");
    alu_ctrl = ALU_OR;
    for (i = 0; i < 10; i++) begin
      a = {$random(), $random()};
      b = {$random(), $random()};
      #(DELAY);
      check_result(a | b);
    end

    // ── XOR ────────────────────────────────────────────────────────────────
    $display("Testing XOR...");
    alu_ctrl = ALU_XOR;
    for (i = 0; i < 10; i++) begin
      a = {$random(), $random()};
      b = {$random(), $random()};
      #(DELAY);
      check_result(a ^ b);
    end

    // ── SLL ────────────────────────────────────────────────────────────────
    $display("Testing SLL...");
    alu_ctrl = ALU_SLL;
    for (i = 0; i < 10; i++) begin
      a = {$random(), $random()};
      b = {$random(), $random()};
      #(DELAY);
      check_result(a << b[5:0]);
    end
    // shift by 0 — unchanged
    a = 64'hDEADBEEFDEADBEEF; b = 64'h0;
    #(DELAY);
    check_result(64'hDEADBEEFDEADBEEF);
    // shift by 63
    a = 64'h1; b = 64'h3F;
    #(DELAY);
    check_result(64'h8000000000000000);
    // shift out all bits
    a = 64'hFFFFFFFFFFFFFFFF; b = 64'h3F;
    #(DELAY);
    check_result(64'h8000000000000000);

    // ── SRL ────────────────────────────────────────────────────────────────
    $display("Testing SRL...");
    alu_ctrl = ALU_SRL;
    for (i = 0; i < 10; i++) begin
      a = {$random(), $random()};
      b = {$random(), $random()};
      #(DELAY);
      check_result(a >> b[5:0]);
    end
    // zero fill on negative value
    a = 64'hFFFFFFFFFFFFFFFF; b = 64'h4;
    #(DELAY);
    check_result(64'h0FFFFFFFFFFFFFFF);
    // shift by 0 — unchanged
    a = 64'hDEADBEEFDEADBEEF; b = 64'h0;
    #(DELAY);
    check_result(64'hDEADBEEFDEADBEEF);

    // ── SRA ────────────────────────────────────────────────────────────────
    $display("Testing SRA...");
    alu_ctrl = ALU_SRA;
    for (i = 0; i < 10; i++) begin
      a = {$random(), $random()};
      b = {$random(), $random()};
      #(DELAY);
      check_result($signed(a) >>> b[5:0]);
    end
    // sign fill on negative value
    a = 64'hFFFFFFFFFFFFFFFF; b = 64'h4;
    #(DELAY);
    check_result(64'hFFFFFFFFFFFFFFFF);
    // zero fill on positive value
    a = 64'h7FFFFFFFFFFFFFFF; b = 64'h4;
    #(DELAY);
    check_result(64'h07FFFFFFFFFFFFFF);
    // shift by 0 — unchanged
    a = 64'hDEADBEEFDEADBEEF; b = 64'h0;
    #(DELAY);
    check_result(64'hDEADBEEFDEADBEEF);

    // ── SLT ────────────────────────────────────────────────────────────────
    $display("Testing SLT...");
    alu_ctrl = ALU_SLT;
    // pos < pos
    a = 64'h0000000000000001; b = 64'h0000000000000002;
    #(DELAY); check_result(64'h1);
    // pos >= pos
    a = 64'h0000000000000002; b = 64'h0000000000000001;
    #(DELAY); check_result(64'h0);
    // neg < pos (signed)
    a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0000000000000001;
    #(DELAY); check_result(64'h1);
    // pos > neg (signed)
    a = 64'h0000000000000001; b = 64'hFFFFFFFFFFFFFFFF;
    #(DELAY); check_result(64'h0);
    // equal
    a = 64'hDEADBEEFDEADBEEF; b = 64'hDEADBEEFDEADBEEF;
    #(DELAY); check_result(64'h0);
    // most negative < most positive
    a = 64'h8000000000000000; b = 64'h7FFFFFFFFFFFFFFF;
    #(DELAY); check_result(64'h1);
    // overflow case: pos - neg overflows but SLT still correct
    a = 64'h7FFFFFFFFFFFFFFF; b = 64'h8000000000000000;
    #(DELAY); check_result(64'h0);  // 0x7FFF... > 0x8000... signed

    // ── SLTU ───────────────────────────────────────────────────────────────
    $display("Testing SLTU...");
    alu_ctrl = ALU_SLTU;
    // small < large
    a = 64'h0000000000000001; b = 64'h0000000000000002;
    #(DELAY); check_result(64'h1);
    // large >= small (0xFFFF... is largest unsigned)
    a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0000000000000001;
    #(DELAY); check_result(64'h0);
    // 0 < anything nonzero
    a = 64'h0; b = 64'h1;
    #(DELAY); check_result(64'h1);
    // equal
    a = 64'hDEADBEEFDEADBEEF; b = 64'hDEADBEEFDEADBEEF;
    #(DELAY); check_result(64'h0);
    // 0xFFFF... is NOT less than 0x0001 unsigned
    a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0000000000000001;
    #(DELAY); check_result(64'h0);

    $display("=== all tests passed ===");
    $finish;
  end

endmodule  // alu_tb
