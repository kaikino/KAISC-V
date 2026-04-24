// log2(D):D decoder
// Depth must be a power of 2, and sel is log2(Depth) bits wide

module dec #(
  parameter DEPTH = 32,
  parameter SEL   = $clog2(DEPTH)
) (
  input  logic [SEL-1:0]   in,
  input  logic             enable,
  output logic [DEPTH-1:0] out
);

  // level[l] holds the enable lines entering stage s
  logic [DEPTH-1:0] level [SEL+1];

  // initialize enable wire
  assign level[0][0] = enable;

  genvar l, k;
  generate
    for (l = 0; l < SEL; l++) begin : eachLevel
      // at level s there are 2^l active dec1_2s
      for (k = 0; k < (1 << l); k++) begin : eachDec
        dec1_2 d (.in(in[l]), .enable(level[l][k]), .out(level[l+1][k*2 +: 2]));
      end
    end
  endgenerate

  assign out = level[SEL][DEPTH-1:0];

endmodule  // dec
