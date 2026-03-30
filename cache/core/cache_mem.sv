import cache_pkg::*;

module cache_mem (
    cache_mem_if.slave ctrl_if
);

  // Storage arrays
  cacheblock_t blocks[NUM_OF_CACHE_LINES];
  tag_t        tags  [NUM_OF_CACHE_LINES];
  valid_t      valids[NUM_OF_CACHE_LINES];


  always_ff @(posedge ctrl_if.clk) begin : rd_wr
    if (ctrl_if.rst) begin
      tags   <= '{default: 0};
      valids <= '{default: 0};
      blocks <= '{default: 0};
    end else begin
      if (ctrl_if.wr_en) begin : wr_enabled
        tags[ctrl_if.wr_idx]   <= ctrl_if.wr_tag;
        valids[ctrl_if.wr_idx] <= ctrl_if.wr_valid;
        blocks[ctrl_if.wr_idx] <= ctrl_if.wr_block;
      end
      ctrl_if.block <= blocks[ctrl_if.rd_idx];
      ctrl_if.valid <= valids[ctrl_if.rd_idx];
      ctrl_if.tag   <= tags[ctrl_if.rd_idx];
    end
  end
endmodule
