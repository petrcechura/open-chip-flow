class i2c_pl_sequencer extends uvm_sequencer #(i2c_pl_seq_item, i2c_pl_seq_item);

`uvm_component_utils(i2c_pl_sequencer)

function new(string name = "i2c_pl_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction

endclass: i2c_pl_sequencer
