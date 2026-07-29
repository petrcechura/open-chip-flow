

module i2c_slave (
    input logic clk,
    input logic arst,

    inout wire sda,
    input wire scl,

    // TODO wishbone bus
);

    i2c_slave_core i2c_slave_core_i(
        .clk(clk),
        .arst(arst),

        .sda(sda),
        .scl(scl),

        .tx_start,
        .data_in,
        .data_out,
    // [0] = data valid
    // [1] = ack
    // [2] = nack
    // [3] = reserved
        .status
    );


    
endmodule