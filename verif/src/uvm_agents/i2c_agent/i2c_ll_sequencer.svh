
class i2c_ll_sequencer extends uvm_sequencer #(i2c_ll_seq_item, i2c_ll_seq_item);

`uvm_component_utils(i2c_ll_sequencer)

function new(string name = "i2c_ll_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction

task run_phase(uvm_phase phase);

  set_report_verbosity_level(UVM_HIGH);

endtask: run_phase

endclass: i2c_ll_sequencer
