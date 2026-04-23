// 64-bit Kogge-Stone carry prefix adder

module adder64 (
  input  logic [63:0] a, b,
  input  logic        cin,
  output logic [63:0] sum,
  output logic        cout
);

  // level 0: bit-level generate and propagate
  // bit 0 — fold cin in as phantom generate at index -1
  logic g0_raw;
  and ag0 (g0_raw,  a[0], b[0]);
  or  op0 (P[0][0], a[0], b[0]);
  pg_cell cin_cell (.ghi (g0_raw), .phi (P[0][0]), .glo (cin), .plo (1'b0), .gout(G[0][0]), .pout());
  // bits 1-63 — normal
  genvar i;
  generate
    for (i = 1; i < 64; i++) begin : initGP
      and ag (G[0][i], a[i], b[i]);
      or  op (P[0][i], a[i], b[i]);
    end
  endgenerate

  // levels 1-6: prefix tree
  genvar s;
  generate
    for (s = 1; s <= 6; s++) begin : eachlevel
      for (i = 0; i < 64; i++) begin : eachBit
        if (i >= (1 << (s-1))) begin : hasNeighbor
          // combine with bit (i - 2^(s-1))
          pg_cell pg (
            .ghi (G[s-1][i]),
            .phi (P[s-1][i]),
            .glo (G[s-1][i - (1 << (s-1))]),
            .plo (P[s-1][i - (1 << (s-1))]),
            .gout(G[s][i]),
            .pout(P[s][i])
          );
        end else begin : passThrough
          // no lower neighbor at this distance — pass through unchanged
          assign G[s][i] = G[s-1][i];
          assign P[s][i] = P[s-1][i];
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
      sum_cell sc (.a(a[i]), .b(b[i]), .cin(carry[i]), .s(sum[i]));
    end
  endgenerate

endmodule  // adder64
