// WXD:1 multiplexor
// Depth must be a power of 2, and sel is log2(Depth) bits wide

module mux #(
  parameter WIDTH = 64,
  parameter DEPTH = 32,
  parameter SEL   = $clog2(DEPTH)
) (
  input  logic [DEPTH-1:0][WIDTH-1:0] in,
  input  logic [SEL-1:0]              sel,
  output logic [WIDTH-1:0]            out
);

  genvar i, j, s, k;
  generate
    for (i = 0; i < WIDTH; i++) begin : eachBit
      // build SEL-deep tree of mux2_1s
      logic [DEPTH-1:0] level [SEL:0];

      for (j = 0; j < DEPTH; j++) begin : initLevel
        assign level[0][j] = in[j][i];
      end

      for (s = 0; s < SEL; s++) begin : eachLevel
        for (k = 0; k < DEPTH >> (s+1); k++) begin : eachPair
          mux2_1 m (.i0 (level[s][k*2]), .i1 (level[s][k*2+1]), .sel(sel[s]), .out(level[s+1][k]));
        end
      end

      assign out[i] = level[SEL][0];
    end
  endgenerate

endmodule  // mux
