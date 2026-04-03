import uart_regblock_pkg::*;

module uart (
    input logic clk_i,
    input logic rstn_i,

    input  logic u_rx,
    output logic u_tx

);

  // Register blocks signals
  uart_regblock__in_t hwif_in;
  uart_regblock__out_t hwif_out;

  // Tx signals
  logic tx_done_ack;
  logic tx_busy;

  // Rx signals
  logic rx_done_ack;

  logic cfg_rx_ready_prev_q;
  logic cfg_tx_done_prev_q;

  axi4lite_intf s_axil ();

  // Uart register block
  uart_regblock reg_block (
      .clk(clk_i),
      .rst(rstn_i),

      .s_axil(s_axil.slave),

      .hwif_in (hwif_in),
      .hwif_out(hwif_out)
  );

  uart_tx tx (
      .clk_i(clk_i),
      .rstn_i(rstn_i),
      .done_ack_i(tx_done_ack),
      .start_i(hwif_out.CFG.tx_en.value),
      .data_i(hwif_out.TDR.tx_data.value),
      .cpb_i(hwif_out.CPB.cpb_value.value),

      .done_o(hwif_out.CFG.tx_done.value),
      .busy_o(tx_busy),
      .tx_o  (u_tx)
  );

  uart_rx rx (
      .clk_i(clk_i),
      .rstn_i(rstn_i),
      .rx_i(u_rx),
      .done_ack_i(rx_done_ack),

      .cpb_i(hwif_out.CPB.cpb_value.value),

      .data_o (hwif_in.RDR.rx_data.next),
      .ready_o(hwif_in.CFG.rx_ready.next)
  );


  always_comb begin : signal_comb
    tx_done_ack = cfg_tx_done_prev_q && !hwif_out.CFG.tx_ready.value;
    rx_done_ack = cfg_rx_ready_prev_q && !hwif_out.CFG.rx_ready.value;
  end

  always_ff @(posedge clk_i or negedge rstn_i) begin : signal_seq
    if (!rstn_i) begin
      cfg_rx_ready_prev_q <= '0;
      cfg_tx_done_prev_q  <= '0;
    end else begin
      // Since there is always one assignment to the _q state registers, the
      // _d registers would be unnecessary. That is why prev_q is directly
      // derived from the configuration register.
      cfg_rx_ready_prev_q <= hwif_out.CFG.rx_ready.value;
      cfg_tx_done_prev_q  <= hwif_out.CFG.tx_done.value;
    end
  end

endmodule
