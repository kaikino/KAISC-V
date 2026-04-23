// Testbench for the mux module

`timescale 1ns/10ps

module mux64x32_1_tb();

  logic [63:0] out;
  logic [31:0][63:0] in;
  logic [4:0] sel;
 
  mux dut (.in, .sel, .out);
 
  integer i;
  initial begin
    // fill input with "random" values
    for (i = 0; i < 32; i++) begin
      in[i] = i * 64'h0120408004002001;
    end
    // iterate select to see output 64-bit match corresponding input
    for (i = 0; i < 32; i++) begin
      sel = i; #10;
    end
 
    $stop;
  end  // initial

endmodule  // mux64x32_1_tb
