package rst_agent_pkg;

	import uvm_pkg::*;

    localparam bit RST_ACTIVE_LEVEL_DEFAULT = 1'b1;

	`include "uvm_macros.svh"

	`include "rst_seq_item.svh"
	`include "rst_agent_config.svh"
	`include "rst_sequencer.svh"
	`include "rst_driver.svh"
	`include "rst_agent.svh"
    `include "sequences/rst_seq_rst_assert.svh"

    task rst_assert(int _type, realtime duration);
        automatic rst_sequencer m_rst_sequencer;
        automatic rst_seq_rst_assert seq_rst;
        
        seq_rst = rst_seq_rst_assert::type_id::create("rst_seq_rst_assert");
        
        seq_rst.rst_set(_type, duration);
        
        uvm_config_db#(rst_sequencer)::get(null, "rst_agent", "sequencer", m_rst_sequencer);
        seq_rst.start(m_rst_sequencer);
        
    endtask

endpackage: rst_agent_pkg
