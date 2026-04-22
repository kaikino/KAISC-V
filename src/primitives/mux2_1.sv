// 2:1 multiplexor
// The output will match the corresponding input (i0 or i1) based on
// the value of the selector bit (sel).

module mux2_1 (
  input  logic i0, i1, sel,
  output logic out
);

  logic nsel, out0, out1;
  not n (nsel, sel);
  and a0 (out0, i0, nsel);
  and a1 (out1, i1, sel);
  or  o (out, out1, out0);

endmodule  // mux2_1
