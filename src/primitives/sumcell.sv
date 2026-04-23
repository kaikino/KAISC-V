// 1-bit Kogge-Stone sum cell

module sumcell (
  input  logic a, b, cin,
  output logic sum
);

  logic axb;
  xor x0 (axb, a, b);
  xor x1 (sum, axb, cin);

endmodule  // sumcell
