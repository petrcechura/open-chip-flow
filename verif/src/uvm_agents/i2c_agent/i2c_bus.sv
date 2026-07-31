


module i2c_bus#(
    parameter int DEVICE_COUNT = 2
)
(
    input  wire[DEVICE_COUNT-1:0] sda_o,
    input  wire[DEVICE_COUNT-1:0] sda_t, 
    output wire[DEVICE_COUNT-1:0] sda_i,

    input  wire[DEVICE_COUNT-1:0] scl_o,
    input  wire[DEVICE_COUNT-1:0] scl_t, 
    output wire[DEVICE_COUNT-1:0] scl_i
);

    genvar i;
    generate
        for (i = 0; i < DEVICE_COUNT; i++) begin
            assign sda_i[i] = sda;
            assign scl_i[i] = scl;
        end
    endgenerate

    logic sda;
    logic scl;

    // SDA line
    // --------
    always@(sda_t, sda_o) begin

        logic sda_val;
        sda_val = 1'b1;
        for (int i = 0; i < DEVICE_COUNT; i++) begin
            if (sda_t[i] == 1'b1 && sda_o[i] == 1'b0) begin
                sda_val = 1'b0;
            end
        end

        sda = sda_val;
    end

    // SCL line
    // --------
    always@(scl_t, scl_o) begin

        logic scl_val;
        scl_val = 1'b1;
        for (int i = 0; i < DEVICE_COUNT; i++) begin
            if (scl_t[i] == 1'b1 && scl_o[i] == 1'b0) begin
                scl_val = 1'b0;
            end
        end

        scl = scl_val;
    end

endmodule: i2c_bus