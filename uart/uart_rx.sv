import uart_pkg::*;

module uart_rx (
    input logic clk_i,
    input logic rstn_i,

    input cpb_t cpb_i,

    input logic rx_i,
    input logic done_ack_i,

    output data_t data_o,
    output logic  ready_o
);

  // State registers and next state signals.
  rx_state_t state_q, state_d;
  cpb_t cpb_cnt_q, cpb_cnt_d;
  bit_cnt_t bit_cnt_q, bit_cnt_d;
  data_t data_q, data_d;

  // Synch registers for rx_i
  logic rx_syn0_q, rx_syn1_q;
  logic  rx_syn1_q_prev;

  // Just-placeholder signals. They are actually place holder for rather
  // complex combitnational logic.
  logic  cpb_done;
  logic  cpb_half_done;
  logic  is_last_bit;

  // Internals signals for outputs
  logic  ready_o_c;
  data_t data_o_c;

  // Instead of assignments here :).
  always_comb begin
    cpb_done = cpb_cnt_q == cpb_i - 1;
    cpb_half_done = (cpb_cnt_q == (cpb_i >> 1) - 1);
    is_last_bit = bit_cnt_q == bit_cnt_t'(DATA_W - 1);
  end

  always_comb begin : output_comb
    data_d = data_q;
    bit_cnt_d = bit_cnt_q;
    cpb_cnt_d = cpb_cnt_q;

    data_o_c = '0;
    ready_o_c = '0;

    unique case (state_q)
      RX_IDLE: begin
        data_d = '0;
        bit_cnt_d = '0;
        cpb_cnt_d = '0;
      end
      RECIEVE_START: begin
        if (cpb_half_done) begin
          cpb_cnt_d = 0;
        end else begin
          cpb_cnt_d = cpb_cnt_q + 1;
        end
      end
      RECIEVE_DATA: begin
        if (cpb_done) begin
          data_d = {rx_syn1_q, data_q[DATA_W-1:1]};
          cpb_cnt_d = '0;
          bit_cnt_d = bit_cnt_q + 1;
        end else begin
          cpb_cnt_d = cpb_cnt_q + 1;
        end
      end
      RECIEVE_STOP: begin
        if (cpb_done) begin
          cpb_cnt_d = '0;
        end else begin
          cpb_cnt_d = cpb_cnt_q + 1;
        end
      end
      RX_WAIT_ACK: begin
        ready_o_c = 1;
        data_o_c  = data_q;
        cpb_cnt_d = '0;
        bit_cnt_d = '0;
      end
    endcase
  end

  always_comb begin : fsm_comb
    state_d = state_q;

    unique case (state_q)
      RX_IDLE: begin
        if (rx_syn1_q_prev == STOP_BIT && rx_syn1_q == START_BIT) begin
          state_d = RECIEVE_START;
        end
      end
      RECIEVE_START: begin
        if (cpb_half_done && rx_syn1_q == START_BIT) begin
          state_d = RECIEVE_DATA;
        end else if (cpb_half_done && rx_syn1_q != START_BIT) begin
          state_d = RX_IDLE;
        end
      end
      RECIEVE_DATA: begin
        if (is_last_bit && cpb_done) begin
          state_d = RECIEVE_STOP;
        end
      end
      RECIEVE_STOP: begin
        if (cpb_done) begin
          if (rx_syn1_q == STOP_BIT) begin
            state_d = RX_WAIT_ACK;
          end else begin
            state_d = RX_IDLE;
          end
        end
      end
      RX_WAIT_ACK: begin
        if (done_ack_i) begin
          state_d = RX_IDLE;
        end
      end
    endcase
  end

  always_ff @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
      state_q <= RX_IDLE;
      data_q <= '0;
      bit_cnt_q <= '0;
      cpb_cnt_q <= '0;

      rx_syn0_q <= STOP_BIT;
      rx_syn1_q <= STOP_BIT;
    end else begin
      state_q <= state_d;
      data_q <= data_d;
      bit_cnt_q <= bit_cnt_d;
      cpb_cnt_q <= cpb_cnt_d;

      rx_syn0_q <= rx_i;
      rx_syn1_q <= rx_syn0_q;
      rx_syn1_q_prev <= rx_syn1_q;
    end
  end

  // Driving outputs from internal signals.
  assign data_o  = data_o_c;
  assign ready_o = ready_o_c;

endmodule
