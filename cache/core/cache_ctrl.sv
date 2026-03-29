import cache_pkg::*;

module cache_ctrl (
    cache_mem_if.master c_if,
    cache_req_if.slave  c_req_if
);

  offset_t      rd_offset_in;
  offset_t      wr_offset_in;

  tag_t         rd_tag_in;
  tag_t         wr_tag_in;

  index_t       rd_index_in;
  index_t       wr_index_in;

  word_select_t rd_word_select;
  word_select_t wr_word_select;

  cacheblock_t  new_block;

  // Read related assingments
  assign rd_offset_in   = cache_req_if.rd_addr[OFFSET_MSB:OFFSET_LSB];
  assign rd_tag_in      = cache_req_if.rd_addr[TAG_MSB:TAG_LSB];
  assign rd_index_in    = cache_req_if.rd_addr[INDEX_MSB:INDEX_LSB];

  assign rd_word_select = rd_offset_in[WORD_SELECT_MSB:WORD_SELECT_LSB];

  // Write related assingments
  assign wr_offset_in   = cache_req_if.wr_addr[OFFSET_MSB:OFFSET_LSB];
  assign wr_tag_in      = cache_req_if.wr_addr[TAG_MSB:TAG_LSB];
  assign wr_index_in    = cache_req_if.wr_addr[INDEX_MSB:INDEX_LSB];

  assign wr_word_select = wr_offset_in[WORD_SELECT_MSB:WORD_SELECT_LSB];

endmodule
