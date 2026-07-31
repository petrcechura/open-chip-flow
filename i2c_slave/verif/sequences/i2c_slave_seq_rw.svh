
class i2c_slave_seq_rw extends uvm_sequence #(i2c_seq_item);

    `uvm_object_utils(i2c_slave_seq_rw)

    function new(string name = "i2c_slave_seq_rw");
        super.new(name);
    endfunction

    const bit[6:0] ADDR = 7'b0000110;
    const bit      BIT_RD = 1'b0;
    const bit      BIT_WR = 1'b1;

    task body;
      	automatic i2c_seq_item frame = i2c_seq_item::type_id::create("frame");

        // Set clock running (20ns)
        // ------------------------
        `uvm_info("application", "Setting a clock to 50 MHz.", UVM_MEDIUM);
        clk_set_period(i2c_slave_env_pkg::CLK_I2C_SLAVE, 20ns);
        clk_on(i2c_slave_env_pkg::CLK_I2C_SLAVE);

        // Resetting DUT
        // -------------
        `uvm_info("application", "Resseting DUT for 20ns...", UVM_MEDIUM);
        rst_assert(i2c_slave_env_pkg::RST_I2C_SLAVE, 200ns);

        #2000ns;

      	// Send custom data
        // ----------------
        `uvm_info("application", "Writing data to first reg...", UVM_MEDIUM);
      	start_item(frame);

        frame.addr = ADDR;
        frame.data.push_back({ADDR, BIT_WR});
        frame.data.push_back(8'b00000001);
        frame.data.push_back(8'b11001010);
        frame.ack = 1'b1;
        frame.scl_period = 30;
      	finish_item(frame);

        #1000ns;

        `uvm_info("application", "Writing data to second reg...", UVM_MEDIUM);
      	start_item(frame);

        frame.addr = ADDR;
        frame.data.delete();
        frame.data.push_back({ADDR, BIT_WR});
        frame.data.push_back(8'b00000010);
        frame.data.push_back(8'b00110110);
        frame.ack = 1'b1;
        frame.scl_period = 30;
      	finish_item(frame);

        #1000ns;

        `uvm_info("application", "Trying to access unknown device...", UVM_MEDIUM);
      	start_item(frame);

        frame.addr = ADDR;
        frame.data.delete();
        frame.data.push_back(8'b11110000);
        frame.data.push_back(8'b00000010);
        frame.data.push_back(8'b00110110);
        frame.ack = 1'b1;
        frame.scl_period = 30;
        finish_item(frame);

        clk_off(i2c_slave_env_pkg::CLK_I2C_SLAVE);

    
    endtask: body

endclass: i2c_slave_seq_rw
