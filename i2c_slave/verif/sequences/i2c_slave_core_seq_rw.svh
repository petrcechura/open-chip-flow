
class i2c_slave_core_seq_rw extends uvm_sequence #(i2c_seq_item);

    `uvm_object_utils(i2c_slave_core_seq_rw)

    function new(string name = "i2c_slave_core_seq_rw");
        super.new(name);
    endfunction

    const bit[6:0] ADDR = 7'b0001101;

    task body;
      	automatic i2c_seq_item frame = i2c_seq_item::type_id::create("frame");

        // Set clock running (20ns)
        // ------------------------
        `uvm_info("application", "Setting a clock to 50 MHz.", UVM_MEDIUM);
        clk_set_period(i2c_slave_core_env_pkg::CLK_I2C_SLAVE_CORE, 20ns);
        clk_on(i2c_slave_core_env_pkg::CLK_I2C_SLAVE_CORE);

        // Resetting DUT
        // -------------
        `uvm_info("application", "Resseting DUT for 20ns...", UVM_MEDIUM);
        rst_assert(i2c_slave_core_env_pkg::RST_I2C_SLAVE_CORE, 200ns);

        #2000ns;

      	// Send custom data
        // ----------------
        `uvm_info("command", "Sending custom data...", UVM_MEDIUM);
      	start_item(frame);

        frame.addr = ADDR;
        frame.data.push_back(8'b10101010);
        frame.data.push_back(8'b11001100);
        frame.ack = 1'b1;
        frame.scl_period = 30;
        frame.delay = 0;
        frame.rst_n = 1'b1;
      	finish_item(frame);

        clk_off(i2c_slave_core_env_pkg::CLK_I2C_SLAVE_CORE);

    
    endtask: body

endclass: i2c_slave_core_seq_rw
