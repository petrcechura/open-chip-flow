
class i2c_slave_core_seq_clk extends uvm_sequence #(clk_seq_item);

    `uvm_object_utils(i2c_slave_core_seq_clk)

    function new(string name = "i2c_slave_core_seq_clk");
        super.new(name);
    endfunction

    task body;
      	automatic clk_seq_item item = clk_seq_item::type_id::create("frame");

      	// Put clock on
        `uvm_info("seq_clk", "Setting clock period to 20ns", 1);
      	start_item(item);

        item.clk_period = 20ns;
        item.clk_type = 0;
        item.clk_en = 1'b1;
      	finish_item(item);

        #((item.clk_period)*10);

    endtask: body

endclass: i2c_slave_core_seq_clk
