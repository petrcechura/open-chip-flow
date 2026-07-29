package rst_agent_pkg;

	import uvm_pkg::*;

	`include "uvm_macros.svh"

	`include "rst_seq_item.svh"
	`include "rst_agent_config.svh"
	`include "rst_sequencer.svh"
	`include "rst_driver.svh"
	`include "rst_agent.svh"
    `include "sequences/rst_seq_rst_assert.svh"

    task rst_assert(int _type);

        
    endtask

    /*
    task clk_on(int _type);
        automatic clk_sequencer m_clk_sequencer;
        automatic clk_seq_single_clk_set seq_clk;
        
        seq_clk = clk_seq_single_clk_set::type_id::create("clk_seq_single_clk_set");
        
        seq_clk.clk_set(_type, 1'b1);
        
        uvm_config_db#(clk_sequencer)::get(null, "clk_agent", "sequencer", m_clk_sequencer);
        seq_clk.start(m_clk_sequencer);
        
    endtask

    task clk_off(int _type);
        automatic clk_sequencer m_clk_sequencer;
        automatic clk_seq_single_clk_set seq_clk;
        
        seq_clk = clk_seq_single_clk_set::type_id::create("clk_seq_single_clk_set");
        
        seq_clk.clk_set(_type, 1'b0);
        
        uvm_config_db#(clk_sequencer)::get(null, "clk_agent", "sequencer", m_clk_sequencer);
        seq_clk.start(m_clk_sequencer);
    endtask

    task clk_set_period(int _type, realtime period);
        automatic clk_sequencer m_clk_sequencer;
        automatic clk_seq_single_clk_set seq_clk;
        
        seq_clk = clk_seq_single_clk_set::type_id::create("clk_seq_single_clk_set");
        
        seq_clk.clk_period(_type, period);
        
        uvm_config_db#(clk_sequencer)::get(null, "clk_agent", "sequencer", m_clk_sequencer);
        seq_clk.start(m_clk_sequencer);
    endtask
    */

endpackage: rst_agent_pkg
