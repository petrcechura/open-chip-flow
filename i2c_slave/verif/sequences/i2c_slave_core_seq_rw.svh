
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
        clk_set_period(i2c_slave_core_env_pkg::CLK_I2C_SLAVE_CORE, 20ns);
        clk_on(i2c_slave_core_env_pkg::CLK_I2C_SLAVE_CORE);

      	// Reset DUT
        // ---------
        `uvm_info("seq_rw", "Resetting DUT...", 1);
      	start_item(frame);

        frame.rst_n = 1'b0;
        frame.scl_period = 5;

      	finish_item(frame);

        #50ns;

      	// Sending custom data
        // -------------------
        `uvm_info("seq_rw", "Sending custom data...", 1);
      	start_item(frame);

        frame.addr = ADDR;
        frame.data.push_back(8'b10101010);
        frame.data.push_back(8'b11001100);
        frame.ack = 1'b1;
        frame.scl_period = 5;
        frame.delay = 0;
        frame.rst_n = 1'b1;
      	finish_item(frame);

        clk_off(i2c_slave_core_env_pkg::CLK_I2C_SLAVE_CORE);

    
    endtask: body

endclass: i2c_slave_core_seq_rw
