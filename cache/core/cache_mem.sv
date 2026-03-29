import cache_pkg::*;

module cache_mem (
    cache_mem_if.slave cntrl_if
);

  // Storage arrays
  cacheblock_t blocks[NUM_OF_CACHE_LINES];
  tag_t        tags  [NUM_OF_CACHE_LINES];
  valid_t      valids[NUM_OF_CACHE_LINES];


  always_ff @(posedge clk_i) begin : rd_wr
    if (cntrl_if.res_i) begin
      tags   <= '{default: 0};
      valids <= '{default: 0};
      blocks <= '{default: 0};
    end else begin
      if (cntrl_if.wr_en_i) begin : wr_enabled
        tags[cntrl_if.wr_idx]   <= cntrl_if.wr_tag;
        valids[cntrl_if.wr_idx] <= cntrl_if.wr_valid;
        blocks[cntrl_if.wr_idx] <= cntrl_if.wr_block;
      end
      block_o <= blocks[cntrl_if.rd_idx];
      valid_o <= valids[cntrl_if.rd_idx];
      tag_o   <= tags[cntrl_if.rd_idx];
    end
  end
endmodule
