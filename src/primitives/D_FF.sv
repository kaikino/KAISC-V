// 1 bit DFF

module D_FF (
  input  logic clk, reset,
  input  logic d,
  output logic q
);

  always_ff @(posedge clk)
    q <= reset ? 0 : d;

endmodule  // D_FF
