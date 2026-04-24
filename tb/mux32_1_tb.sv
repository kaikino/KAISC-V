// Testbench for the mux module with 1 bit width

`timescale 1ns/10ps

module mux32_1_tb();

  logic out;
  logic [31:0] in;
  logic [4:0] sel;

  mux #(.WIDTH(1)) dut (.in, .sel, .out);

  integer i;
  initial begin
    in = 32'b0;
    // increment sel by 1 each iteration, and set input to some random sequence
    for (i = 0; i < 32; i++) begin
      in = (1 << i) * i;
      sel = i; #10;
    end

    // check lowest and highest sel
    sel = 5'd0; in = '1; #10;
    sel = 5'd31; #10;
    sel = 5'd0; in = '0; #10;

    $stop;
  end  // initial

endmodule  // mux32_1_tb
