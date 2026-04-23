// 64-bit register
// Write out to DFFs if enable

module reg64 (
  input  logic        clk,
  input  logic [63:0] in,
  input  logic        enable,
  output logic [63:0] out
);

  logic [63:0] next;  // if enable, this is in; otherwise out

  genvar i;
  generate
    for (i = 0; i < 64; i++) begin : eachBit
      // i0: current value; i1: new write value
      mux2_1 m (.i0(out[i]), .i1(in[i]), .sel(enable), .out(next[i]));
      D_FF d (.clk, .reset(1'b0), .d(next[i]), .q(out[i]));
    end
  endgenerate

endmodule  // reg64
