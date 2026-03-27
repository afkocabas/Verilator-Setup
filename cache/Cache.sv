import CachePackage::*;

// Simple read-only direct mapped cache with 4 kb data capacity.
module Cache (
    input logic     res,
    input logic     clock,
    input logic     read_enable,
    input address_t address,

    output word_t read_data,
    output logic  is_Hit
);

  // Internal Blocks:   {
  cacheblock_t  data        [NUM_OF_CACHE_LINES];
  offset_t      offset      [NUM_OF_CACHE_LINES];
  tag_t         tag         [NUM_OF_CACHE_LINES];
  valid_t       valid       [NUM_OF_CACHE_LINES];

  offset_t      offset_in;
  tag_t         tag_in;
  index_t       index_in;

  cacheblock_t  data_block;

  word_select_t word_select;
  // ------------------ }

  // Assignments:    {
  assign offset_in   = address[OFFSET_MSB:OFFSET_LSB];
  assign tag_in      = address[TAG_MSB:TAG_LSB];
  assign index_in    = address[INDEX_MSB:INDEX_LSB];
  assign data_block  = data[index_in];
  assign word_select = offset_in[WORD_SELECT_MSB:WORD_SELECT_LSB];

  // ----------------}


  always_ff @(posedge clock) begin : reading
    // Reset  logic goes here
    if (res) begin
      is_Hit <= '0;
      read_data <= '0;
      valid <= '{default: 0};
    end else begin
      if (read_enable) begin
        if (valid[index_in] && (tag[index_in] == tag_in)) begin  // Cache hit
          is_Hit <= 1;
          /*
          TODO: read_data is a 32 bit word while data[index] is a cache line of 512 bits.
            */
          read_data <= data_block[word_select*WORD_SIZE_IN_BITS+:WORD_SIZE_IN_BITS];
        end else begin  // Cache miss.
          is_Hit <= 0;
        end
        // Clear output signals
      end else begin
        is_Hit <= 0;
      end
    end
  end

endmodule
