// 1:2 decoder
// out[0] = enable & ~in
// out[1] = enable &  in

module dec1_2 (
  input  logic       in,
  input  logic       enable,
  output logic [1:0] out
);

  logic nin;
  not n  (nin,in);
  and a0 (out[0], enable, nin);
  and a1 (out[1], enable, in);

endmodule  // dec1_2
