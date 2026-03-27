import CachePackage::*;

// Simple read-only direct mapped cache with 4 kb data capacity.
module Cache (
    input logic     res,
    input logic     clock,
    input logic     read_enable,
    input address_t address,

    input logic  write_enable,
    input word_t write_data,

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
  cacheblock_t  new_block;

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
          read_data <= getWordFromCacheBlock(data_block, word_select);
        end else begin  // Cache miss.
          is_Hit <= 0;
        end
        // Clear output signals
      end else begin
        is_Hit <= 0;
      end
    end
  end

  always_ff @(posedge clock) begin : writing
    if (res) begin
      is_Hit <= '0;
      read_data <= '0;
      valid <= '{default: 0};
    end else begin
      // If write is enabled.
      if (write_enable) begin
        /*
        TODO: Simplified write-miss handling.
        On a write miss, this implementation allocates/overwrites the cache line locally,
        clears the line, and writes only the selected word, instead of fetching the full
        cache line from memory first.
        */
        if (valid[index_in]) begin

          if (tag[index_in] != tag_in) begin  // Write miss, tag mismatch.

            // Set meta data
            tag[index_in]   <= tag_in;
            valid[index_in] <= 1'b1;

            // Write the word
            data[index_in]  <= getNewBlock('0, word_select, write_data);

          end else begin  // Write hit, just adjust the corresponding word.
            data[index_in][word_select*WORD_SIZE_IN_BITS+:WORD_SIZE_IN_BITS] <= write_data;
          end
        end else begin  // Write miss, invalidated cache line.

          // Set meta data
          tag[index_in]   <= tag_in;
          valid[index_in] <= 1'b1;

          // Write the word
          data[index_in]  <= getNewBlock('0, word_select, write_data);

        end
      end
    end
  end
endmodule
