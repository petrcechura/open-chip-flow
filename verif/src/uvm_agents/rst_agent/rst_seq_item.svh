
class rst_seq_item extends uvm_sequence_item;

    `uvm_object_utils(rst_seq_item)

    // specifies clock period
    realtime duration;
    // when 1, clk period is changed in driver
    bit on;
    // which clock (from interface array) modify
    int rst_type;

    /* Standard UVM Methods */
    extern function new(string name = "rst_seq_item");

endclass: rst_seq_item

function rst_seq_item::new(string name = "rst_seq_item");
    super.new(name);
endfunction
