// Testbench for regfile

`timescale 1ns/10ps

module regfile_tb();     

  logic        clk;
  logic [4:0]  rs1, rs2, ws;
  logic [63:0] wd;
  logic        reg_write;
  logic [63:0] rd1, rd2;

  integer i;

  regfile dut (.clk, .rs1, .rs2, .ws, .reg_write, .wd, .rd1, .rd2);

  parameter ClockDelay = 5000;
  initial begin // Set up the clock
    clk <= 0;
    forever #(ClockDelay/2) clk <= ~clk;
  end

  initial begin
    reg_write <= 5'd0;
    rs1 <= 5'd0;
    rs2 <= 5'd0;
    ws <= 5'd31;
    wd <= 64'h00000000000000A0;
    @(posedge clk);

    reg_write <= 1;
    @(posedge clk);

    for (i=0; i<31; i=i+1) begin
      reg_write <= 0;
      rs1 <= i-1;
      rs2 <= i;
      ws <= i;
      wd <= i*64'h0000010204080001;
      @(posedge clk);
      
      reg_write <= 1;
      @(posedge clk);
    end

    for (i=0; i<32; i=i+1) begin
      reg_write <= 0;
      rs1 <= i-1;
      rs2 <= i;
      ws <= i;
      wd <= i*64'h0000000000000100+i;
      @(posedge clk);
    end
    $stop;
  end  // initial

endmodule  // regfile_tb
