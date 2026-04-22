// 32 by 64-bit RISC-V general purpose register file
// 2 read and 1 write port + enable, x0 always 0

module regfile (
  input  logic clk,
  input  logic [4:0]  rs1, rs2,       // read port selects
  input  logic [4:0]  ws,             // write port select
  input  logic        reg_write,      // write enable
  input  logic [63:0] wd,             // write port input
  output logic [63:0] rd1, rd2        // read port outputs
);

  logic [31:0] enables;  // write enable decoded to 32 bits
  dec5_32 dec (.in(ws), .enable(reg_write), .out(enables));

  logic [31:0][63:0] data;
  genvar i;
  generate
    for (i = 1; i < 32; i++) begin : eachReg
      reg64 r (.clk, .in(wd), .enable(enables[i]), .out(data[i]));
    end
  endgenerate

  // 0 register is hardwired to zero
  assign data[0] = 64'b0;

  // select which register to output for each read port
  muxWxD_1 #(.WIDTH(64), .DEPTH(32)) mux1 (.in(data), .sel(rs1), .out(rd1));
  muxWxD_1 #(.WIDTH(64), .DEPTH(32)) mux2 (.in(data), .sel(rs2), .out(rd2));

endmodule  // regfile
