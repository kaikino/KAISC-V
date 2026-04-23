// Testbench for the dec5_32 module

`timescale 1ns/10ps

module dec5_32_tb();
  logic [31:0] out;
  logic [4:0] in;
  logic enable;

  dec dut (.in, .enable, .out);

  integer i;
  initial begin
    enable = 0;
    for (i = 0; i < 32; i++) begin
      in = i; #10;
    end

    enable = 1;
    for (i = 0; i < 32; i++) begin
      in = i; #10;
    end

    $stop;
  end  // initial
endmodule  // dec5_32_tb
