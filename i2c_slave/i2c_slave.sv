

module i2c_slave (
    input logic clk,
    input logic arst,

`ifndef USING_VERILATOR
    inout wire sda,
    inout wire scl,
`else
    input  wire sda_i,
    output wire sda_o,
    output wire sda_t,
    input  wire scl_i,
    output wire scl_o,
    output wire scl_t,
`endif

    // TODO wishbone bus
);
    localparam bit[6:0] ADDR = 7'b1110101;

    typedef enum logic[1:0] {  
        ADDR, // waiting for ADDR
        CMD,  // waiting for CMD
        REG_READ, // reading from register
        REG_WRITE // writing to register
    } state_i2c_t;

    state_i2c_t state_i2c_d, state_i2c_q;

    logic      i2c_sc_tx_start;
    logic      i2c_sc_rx_done;
    logic      i2c_sc_ack_in;
    logic      i2c_sc_ack_out;
    logic[7:0] i2c_sc_data_in;
    logic[7:0] i2c_sc_data_out;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state_i2c_q <= ADDR;
        end else begin
            state_i2c_q <= state_i2c_d;
        end
    end

    always_comb begin
        state_i2c_d = state_i2c_q;
        i2c_sc_ack_in = 1'b1;

        case (state_i2c_q)
            ADDR: begin
                if (rx_done && i2c_sc_data_out == ADDR) begin
                    state_i2c_d = CMD;
                end
            end

            CMD: begin
                i2c_sc_ack_in = 1'b0;
            end
            default: begin

            end
        endcase
    end

    i2c_slave_core i2c_slave_core_i(
        .clk(clk),
        .arst(arst),
`ifndef USING_VERILATOR
        .sda(sda),
        .scl(scl),
`else        
        .sda_i(sda_i),
        .sda_o(sda_o),
        .sda_t(sda_t),
        .scl_i(scl_i),
        .scl_o(scl_o),
        .scl_t(scl_t),
`endif

        .tx_start,
        .rx_done,
        .ack_in,
        .ack_out(),
        .data_in,
        .data_out(i2c_sc_data_out),
    );


    
endmodule