class rst_driver#(parameter int RST_COUNT = 1) extends uvm_driver #(rst_seq_item);

    `uvm_component_utils(rst_driver)
    
    function new(string name = "rst_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    virtual rst_if#(.RST_COUNT(RST_COUNT)) sline;
    
    rst_seq_item seq_item;

    task rst_assert;
        `uvm_info("datalink", $sformatf("RST: %0d. reset set to %b", seq_item.rst_type, seq_item.value), UVM_MEDIUM);
        sline.rst[seq_item.rst_type] = seq_item.value;
    endtask
    
    task run_phase(uvm_phase phase);
        integer bitPtr = 0;

        begin
            
            // Deassert all resets by default
            for (int i = 0; i < RST_COUNT; i++) begin
                automatic bit active_level;
                if (uvm_config_db#(bit)::exists(null, "rst_agent", $sformatf("active_level_%0d", i))) begin
                    uvm_config_db#(bit)::get(null, "rst_agent", $sformatf("active_level_%0d", i), active_level);
                end else begin
                    active_level = ~RST_ACTIVE_LEVEL_DEFAULT;
                end
                
                sline.rst[i] = active_level;
            end

            forever begin
                seq_item_port.get_next_item(seq_item);
                rst_assert;
    
                seq_item_port.item_done();
            end
        end
    endtask: run_phase

endclass: rst_driver
