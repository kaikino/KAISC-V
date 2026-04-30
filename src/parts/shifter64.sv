// Single 64-bit barrel shifter: structural mux2_1 stages only (no case/if on data).
// dir_right=0 => shift left (SLL); dir_right=1 => shift right; arith gates sign fill for SRA.

module shifter64 (
    input  logic [63:0] in,
    input  logic [5:0]  shamt,
    input  logic        dir_right,  // 0=left, 1=right
    input  logic        arith,      // 1=SRA fill (only matters when dir_right=1)
    output logic [63:0] out
);

  logic fill_bit;
  and a_fill (fill_bit, in[63], arith);

  logic [63:0] level [6:0];
  assign level[0] = in;

  genvar l, i;
  generate
    for (l = 0; l < 6; l++) begin : eachLevel
      for (i = 0; i < 64; i++) begin : eachBit
        logic lv_op, rv_op, dir_merged;

        if (i >= (1 << l)) begin : g_lv
          assign lv_op = level[l][i - (1 << l)];
        end else begin : g_lv0
          assign lv_op = 1'b0;
        end

        if (i < 64 - (1 << l)) begin : g_rv
          assign rv_op = level[l][i + (1 << l)];
        end else begin : g_rvf
          assign rv_op = fill_bit;
        end

        mux2_1 m_dir (
            .i0  (lv_op),
            .i1  (rv_op),
            .sel (dir_right),
            .out (dir_merged)
        );

        mux2_1 m_st (
            .i0  (level[l][i]),
            .i1  (dir_merged),
            .sel (shamt[l]),
            .out (level[l+1][i])
        );
      end
    end
  endgenerate

  assign out = level[6];

endmodule
