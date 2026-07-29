class clk_sequencer extends uvm_sequencer #(clk_seq_item, clk_seq_item);

    `uvm_component_utils(clk_sequencer)
    
    function new(string name = "clk_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass: clk_sequencer
