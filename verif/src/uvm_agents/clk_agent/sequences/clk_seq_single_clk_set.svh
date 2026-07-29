
class clk_seq_single_clk_set extends uvm_sequence #(clk_seq_item);

    `uvm_object_utils(clk_seq_single_clk_set)

    function new(string name = "clk_seq_clk_on");
        super.new(name);
    endfunction

    realtime clk_per = 20ns;
    int clk_type = 0;
    bit clk_en = 0;
    bit clk_period_set = 0;

    function clk_set(int _type, bit on);
        clk_type = _type;
        clk_en = on;
    endfunction

    function clk_period(bit _type, realtime period);
        clk_type = _type;
        clk_period_set = 1'b1;
        clk_per = period;
    endfunction

    task body;
      	automatic clk_seq_item item = clk_seq_item::type_id::create("frame");

      	// Put clock on
        `uvm_info("seq_clk", $sformatf("Setting clock period to %t", clk_per), 1);
      	start_item(item);

        item.clk_period = clk_per;
        item.clk_type = clk_type;
        item.clk_en = clk_en;
      	finish_item(item);

    endtask: body

endclass: clk_seq_single_clk_set
