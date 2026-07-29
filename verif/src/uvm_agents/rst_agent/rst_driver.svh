class rst_driver#(parameter int RST_COUNT = 1) extends uvm_driver #(rst_seq_item);

    `uvm_component_utils(rst_driver)
    
    function new(string name = "rst_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    virtual rst_if#(.RST_COUNT(RST_COUNT)) sline;
    
    rst_seq_item seq_item;
    
    logic[RST_COUNT-1:0] rst_actives;

    task rst_assert;
        sline.rst[seq_item.rst_type] = rst_actives[seq_item.rst_type];
        #(seq_item.duration);
        sline.rst[seq_item.rst_type] = ~rst_actives[seq_item.rst_type];
    endtask

    function build_phase(uvm_phase);
        uvm_config_db#(logic[RST_COUNT-1:0])::get(null, "rst_agent", "active_levels", rst_actives);
    endfunction
    
    task run_phase(uvm_phase phase);
        integer bitPtr = 0;

        begin

            // Deassert all resets by default
            for (int i = 0; i < RST_COUNT; i++) begin
                sline.rst[i] = ~rst_actives[i];
            end

            forever begin
                seq_item_port.get_next_item(seq_item);
                rst_assert;
    
                seq_item_port.item_done();
            end
        end
    endtask: run_phase

endclass: rst_driver
