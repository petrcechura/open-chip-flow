
class rst_seq_rst_assert extends uvm_sequence #(rst_seq_item);

    `uvm_object_utils(rst_seq_rst_assert)

    function new(string name = "rst_seq_rst_assert");
        super.new(name);
    endfunction

    int unsigned rst_type;
    realtime duration;

    function rst_set(int unsigned rst_type, realtime duration);
        rst_type = rst_type;
        duration = duration;
    endfunction 


    task body;
      	automatic rst_seq_item item = rst_seq_item::type_id::create("item");
        automatic bit active_level;

        if (uvm_config_db#(bit)::exists(null, "i2c_agent", $sformatf("active_level_%d", rst_type))) begin
            uvm_config_db#(bit)::get(null, "i2c_agent", $sformatf("active_level_%d", rst_type), active_level);
        end else begin
            `uvm_warning("rst_agent", $sformatf("Active level for rst: %0d not found in config_db! Assuming active high by default...", rst_type));
            active_level = RST_ACTIVE_LEVEL_DEFAULT;
        end

      	// put reset on
        `uvm_info("seq_rst", $sformatf("%t: .. RESET[%0d] (active %s) for %0t...", $realtime, rst_type, (active_level ? "high" : "low"), duration), UVM_MEDIUM);
      	
        start_item(item);
        item.rst_type = rst_type;
        item.value = active_level;
      	finish_item(item);
        
        #(duration);

        start_item(item);
        item.rst_type = rst_type;
        item.value = ~active_level;
      	finish_item(item);

        `uvm_info("seq_rst", $sformatf("%t: .. RESET[%0d] released...", $realtime, rst_type, duration), UVM_MEDIUM);

    endtask: body

endclass: rst_seq_rst_assert
