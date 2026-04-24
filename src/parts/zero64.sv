// 64-bit zero detector

module zero64 (
  input  logic [63:0] in,
  output logic        out
);

  // NOR pairs of input bits — if both are 0, output is 1
  // then AND the results up a tree to a single bit
  logic [31:0] l1;
  logic [15:0] l2;
  logic [7:0]  l3;
  logic [3:0]  l4;
  logic [1:0]  l5;

  genvar i;
  generate
    for (i = 0; i < 32; i++) begin : level1
      nor n5 (l1[i], in[i*2], in[i*2+1]);
    end
    for (i = 0; i < 16; i++) begin : level2
      and a4 (l2[i], l1[i*2], l1[i*2+1]);
    end
    for (i = 0; i < 8; i++) begin : level3
      and a3 (l3[i], l2[i*2], l2[i*2+1]);
    end
    for (i = 0; i < 4; i++) begin : level4
      and a2 (l4[i], l3[i*2], l3[i*2+1]);
    end
    for (i = 0; i < 2; i++) begin : level5
      and a1 (l5[i], l4[i*2], l4[i*2+1]);
    end
  endgenerate

  and a0 (out, l5[0], l5[1]);

endmodule  // zero64
