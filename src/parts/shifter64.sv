// Left and Right 64-bit shifters

module lshift64 (
  input  logic [63:0] in,
  input  logic [5:0]  shamt,
  output logic [63:0] out
);

  logic [63:0] level [6:0];
  assign level[0] = in;

  genvar l, i;
  generate
    for (l = 0; l < 6; l++) begin : eachLevel
      for (i = 0; i < 64; i++) begin : eachBit
        if (i >= (1 << l)) begin
          // take bit from 2^s positions back
          mux2_1 m (.i0(level[l][i]), .i1(level[l][i - (1 << l)]), .sel(shamt[l]), .out(level[l+1][i]));
        end else begin
          // bit position too low to shift
          mux2_1 m (.i0(level[l][i]), .i1(1'b0), .sel(shamt[l]), .out(level[l+1][i]));
        end
      end
    end
  endgenerate

  assign out = level[6];

endmodule  // lshift64


module rshift64 (
  input  logic [63:0] in,
  input  logic [5:0]  shamt,
  input  logic        arithmetic,   // 0=logical(SRL), 1=arithmetic(SRA)
  output logic [63:0] out
);

  // fill bit — 0 for logical, in[63] for arithmetic
  logic fill;
  and a (fill, in[63], arithmetic);

  logic [63:0] level [6:0];
  assign level[0] = in;

  genvar l, i;
  generate
    for (l = 0; l < 6; l++) begin : eachLevel
      for (i = 0; i < 64; i++) begin : eachBit
        if (i < 64 - (1 << l)) begin
          mux2_1 m (.i0(level[l][i]), .i1(level[l][i + (1 << l)]), .sel(shamt[l]), .out(level[l+1][i]));
        end else begin
          // bit position too high
          mux2_1 m (.i0(level[l][i]), .i1(fill), .sel(shamt[l]), .out(level[l+1][i]));
        end
      end
    end
  endgenerate

  assign out = level[6];

endmodule  // rshift64
