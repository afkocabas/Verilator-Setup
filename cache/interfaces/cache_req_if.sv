import cache_pkg::*;

interface cache_req_if (
    input clk
);

  address_t wr_addr;
  address_t rd_addr;

  logic res;

  logic write_en;
  logic read_en;

  logic is_hit;

  word_t wr_data;
  word_t rd_data;


  modport master(
      output res,

      output write_en,
      output read_en,

      output wr_addr,
      output rd_addr,

      output wr_data,

      input rd_data,
      input is_hit
  );

  modport slave(
      input res,

      input write_en,
      input read_en,

      input wr_addr,
      input rd_addr,

      input wr_data,

      output rd_data,
      output is_hit
  );


endinterface
