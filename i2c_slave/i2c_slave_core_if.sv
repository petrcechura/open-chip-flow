


interface i2c_slave_core_if;

    logic clk;
    logic rst_n;

    wire sda;
    wire scl;
    logic tx_start;
    logic[7:0] data_in;
    logic[7:0] data_out;
    logic[1:0] status;

endinterface