// Testbench for the reg64 module

`timescale 1ns/10ps

module reg64_tb();

  logic clk, enable;
  logic [63:0] in;
  logic [63:0] out;

  reg64 dut (.clk, .in, .enable, .out);

  parameter ClockDelay = 100;

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

  initial begin
    // enable off, should not write
    enable = 0;
    in = 64'hAAAAAAAAAAAAAAAA;
    @(posedge clk);

    // enable on, should write
    enable = 1;
    @(posedge clk);

    // enable off, should not clear
    enable = 0;
    in = 64'h0000000000000000;
    @(posedge clk);

    // enable on, should write
    enable = 1;
    in = 64'h123456789ABCDEF0;
    @(posedge clk);

    // enable on, should write
    in = 64'h1111111111111111;
    @(posedge clk);
    @(posedge clk);

    $stop;
  end

endmodule  // reg64_tb
