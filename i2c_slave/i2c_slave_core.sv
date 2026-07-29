

module i2c_slave_core
(
    input logic clk,
    input logic arst,

    inout wire sda,
    inout wire scl,

    input logic tx_start,
    input logic[7:0] data_in,
    output logic[7:0] data_out,
    // 00 = data valid
    // 01 = ack
    // 10 = nack
    // 11 = reserved
    output logic[1:0] status
);

    typedef enum logic[2:0] {
        IDLE,
        DATA_RX,
        DATA_TX,
        ACK_TX,
        ACK_RX
    } state_t;

    logic[7:0] data_reg_d, data_reg_q;

    // Tri-state logic for I2C interface
    // -----------------------------------

    logic sda_o, sda_i, sda_t;
    logic scl_o, scl_i, scl_t;

    assign sda = (sda_t) ? sda_o : 1'bZ;
    assign sda_i = sda;
    assign scl = (scl_t) ? scl_o : 1'bZ;
    assign scl_i = scl;

    // Metastability removal
    // ---------------------

    logic sda_latched;
    logic scl_latched;
    logic sda_rise;
    logic sda_fall;
    logic scl_rise;
    logic scl_fall;

    rs_det rs_sda_i(
        .clk(clk),
        .sig_in(sda_i),
        .sig_out(sda_latched),
        .rise_edge(sda_rise),
        .fall_edge(sda_fall)
    );

    rs_det rs_scl_i(
        .clk(clk),
        .sig_in(scl_i),
        .sig_out(scl_latched),
        .rise_edge(scl_rise),
        .fall_edge(scl_fall)
    );

    // 3bit counter
    // ------------
    logic[2:0] cntr_3b_q;
    logic cntr_3b_en;
    logic cntr_3b_incr;
    always_ff @(posedge clk or posedge arst) begin
        if (arst) begin
            cntr_3b_q <= '0;
        end
        else if (cntr_3b_en) begin
            if (cntr_3b_incr) begin
                cntr_3b_q <= cntr_3b_q + 1;
            end
            else begin
                cntr_3b_q <= cntr_3b_q;
            end
        end
        else begin
            cntr_3b_q <= '0;
        end
    end

    // Finite state machine
    // --------------------
    state_t state_d, state_q;

    always_ff @(posedge clk or posedge arst) begin
        if (arst) begin
            state_q <= IDLE;
            data_reg_q <= '0;
        end
        else begin
            state_q <= state_d;
            data_reg_q <= data_reg_d;
        end
    end

    always_comb begin
        state_d = state_q;
        cntr_3b_en = 1'b0;
        data_reg_d = data_reg_q;
        cntr_3b_incr = 1'b0;
        scl_o = 1'b0;
        scl_t = 1'b0;
        sda_o = 1'b0;
        sda_t = 1'b0;
        status = 2'b0;

        case (state_q)
            IDLE: begin
                // startbit condition
                if (sda_fall & scl_latched) begin
                    state_d = DATA_RX;
                end

                if (tx_start) begin
                    state_d = DATA_TX;
                end
            end

            DATA_RX: begin
                cntr_3b_en = 1'b1;

                if (cntr_3b_q == 3'd7 & scl_fall) begin
                    state_d = ACK_RX;
                end
                 
                if (scl_rise) begin
                    cntr_3b_incr = 1'b1;
                    data_reg_d[7:1] = data_reg_q[6:0];
                    data_reg_d[0] = sda_latched;
                end
            

                // stopbit condition
                if (scl_latched & sda_rise) begin
                    state_d = IDLE;
                end

            end


            DATA_TX: begin
                sda_t = 1'b1;
                cntr_3b_en = 1'b1;

                sda_o = data_in[7-cntr_3b_q];

                if (scl_fall) begin
                    cntr_3b_incr = 1'b1;
                end

                if (scl_rise && cntr_3b_q == 3'd7) begin
                    state_d = ACK_TX;
                end
            end

            ACK_RX: begin
                sda_t = 1'b1;
                // auto ACK
                sda_o = 1'b0;
                status = 2'b01;

                if (scl_fall) begin
                    state_d = DATA_RX;
                end
            end 

            ACK_TX: begin
                
                if (scl_rise) begin
                    // ACK
                    if (~sda_latched) begin
                        status = 2'b01;
                        state_d = DATA_TX;
                    end
                    // NACK
                    else begin
                        status = 2'b10;
                        state_d = IDLE;
                    end
                end
            end
            default: begin

            end
        endcase
    end

    assign data_out = data_reg_q;

endmodule
