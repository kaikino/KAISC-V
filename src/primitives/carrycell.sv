// 1-bit Kogge-Stone generate-propogate cell

module carrycell (
  input  logic ghi, phi,   // from current bit
  input  logic glo, plo,   // from lower bit
  output logic gout, pout
);

  logic pg;
  and a0 (pg, phi, glo);
  or  o  (gout, ghi, pg);
  and a1 (pout, phi, plo);

endmodule  // carrycell
