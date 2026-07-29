
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
        automatic logic[RST_COUNT-1:0] actives;
        uvm_config_db#(logic[RST_COUNT-1:0])::get(null, "rst_agent", "active_levels", actives);

      	// Put clock on
        `uvm_info("seq_clk", $sformatf("%t: Asserting reset to %0d. reset (active %s)", $realtime, item._type, (actives[item._type] ? "high" : "low")), UVM_MEDIUM);
      	start_item(item);

        item.duration = duration;
        item.rst_type = rst_type;
        item.on = actives[rst_type];
      	finish_item(item);

    endtask: body

endclass: rst_seq_rst_assert
