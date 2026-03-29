import cache_pkg::*;

interface cache_mem_if (
    input clk
);

  logic        res;

  logic        wr_en;
  tag_t        wr_tag;
  valid_t      wr_valid;
  cacheblock_t wr_block;
  index_t      wr_idx;

  index_t      rd_idx;

  tag_t        tag;
  cacheblock_t block;
  valid_t      valid;


  modport master(
      output res,
      output wr_en,

      output wr_tag,
      output wr_valid,
      output wr_block,
      output wr_idx,
      output rd_idx,

      input tag,
      input block,
      input valid

  );

  modport slave(
      input res,
      input wr_en,

      input wr_tag,
      input wr_valid,
      input wr_block,
      input wr_idx,
      input rd_idx,

      output tag,
      output block,
      output valid

  );

endinterface

