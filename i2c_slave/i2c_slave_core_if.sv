


interface i2c_slave_core_if;

    logic clk;
    logic rst_n;

    wire sda;
    wire scl;
    logic tx_start;
    logic rx_done;
    logic ack_drive;
    logic[7:0] data_in;
    logic[7:0] data_out;

endinterface