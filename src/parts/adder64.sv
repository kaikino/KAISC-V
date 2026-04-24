// 64-bit Kogge-Stone carry prefix adder

module adder64 (
  input  logic [63:0] a, b,
  input  logic        cin,
  output logic [63:0] sum,
  output logic        cout,
  output logic        overflow
);

  // level 0: bit-level generate and propagate
  // bit 0 — fold cin in as phantom generate at index -1
  logic g0_raw;
  and ag0 (g0_raw,  a[0], b[0]);
  or  op0 (P[0][0], a[0], b[0]);
  carrycell cc0 (.ghi (g0_raw), .phi (P[0][0]), .glo (cin), .plo (1'b0), .gout(G[0][0]), .pout());
  // bits 1-63 — normal
  genvar i;
  generate
    for (i = 1; i < 64; i++) begin : initGP
      and ag (G[0][i], a[i], b[i]);
      or  op (P[0][i], a[i], b[i]);
    end
  endgenerate

  // levels 1-6: prefix tree
  genvar l;
  generate
    for (l = 1; l <= 6; l++) begin : eachlevel
      for (i = 0; i < 64; i++) begin : eachBit
        if (i >= (1 << (l-1))) begin
          // combine with bit (i - 2^(l-1))
          carrycell cc (
            .ghi (G[l-1][i]),
            .phi (P[l-1][i]),
            .glo (G[l-1][i - (1 << (l-1))]),
            .plo (P[l-1][i - (1 << (l-1))]),
            .gout(G[l][i]),
            .pout(P[l][i])
          );
        end else begin
          // pass through
          assign G[l][i] = G[l-1][i];
          assign P[l][i] = P[l-1][i];
        end
      end
    end
  endgenerate

  // final carries
  logic [63:0] carry;
  assign carry[0] = cin;
  generate
    for (i = 1; i < 64; i++) begin : eachCarry
      assign carry[i] = G[6][i-1];
    end
  endgenerate

  // cout is carry out of bit 63 = G[6][63]
  assign cout = G[6][63];

  // sum bits
  generate
    for (i = 0; i < 64; i++) begin : eachSum
      sumcell sc (.a(a[i]), .b(b[i]), .cin(carry[i]), .s(sum[i]));
    end
  endgenerate

  xor xo (overflow, G[6][62], cout);

endmodule  // adder64
