
class clk_seq_item extends uvm_sequence_item;

    `uvm_object_utils(clk_seq_item)

    // specifies clock period
    realtime clk_period;
    // which clock (from interface array) modify
    int clk_type;
    // 1 = clock is on, 0 = clock is off
    bit clk_en;



    /* Standard UVM Methods */
    extern function new(string name = "clk_seq_item");

endclass: clk_seq_item

function clk_seq_item::new(string name = "clk_seq_item");
    super.new(name);
endfunction
