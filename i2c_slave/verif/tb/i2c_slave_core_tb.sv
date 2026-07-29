`include "uvm.sv"
`include "uvm_macros.svh"

module i2c_slave_core_tb;

    import uvm_pkg::*;

    // Interfaces
    // ----------
    i2c_slave_core_if i2c_slave_core_ifc();
    i2c_if i2c_ifc();
    clk_if clk_ifc();
    
    assign i2c_slave_core_ifc.sda = i2c_ifc.sda_wire;
    assign i2c_slave_core_ifc.scl = i2c_ifc.scl_wire;
    assign i2c_slave_core_ifc.clk = clk_ifc.clk;
    //assign i2c_slave_core_ifc.rst_n = i2c_ifc.rst_n;

    // I2C slave core instance
    // -----------------------
    i2c_slave_core dut (
        .clk(   i2c_slave_core_ifc.clk),
        .arst(  i2c_slave_core_ifc.rst_n),
        .sda(   i2c_slave_core_ifc.sda),
        .scl(   i2c_slave_core_ifc.scl),

        .tx_start(  i2c_slave_core_ifc.tx_start),
        .data_in(   i2c_slave_core_ifc.data_in),
        .data_out(  i2c_slave_core_ifc.data_out),
        .status(    i2c_slave_core_ifc.status)
    );

    // Test run
    // -----------------------
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars();
        uvm_config_db #(virtual i2c_slave_core_if)::set(null, "uvm_test_top", "i2c_slave_core_ifc", i2c_slave_core_ifc);
        uvm_config_db #(virtual i2c_if)::set(null, "uvm_test_top", "i2c_ifc", i2c_ifc);
        uvm_config_db #(virtual clk_if)::set(null, "uvm_test_top", "clk_ifc", clk_ifc);
        run_test();
    end

endmodule
