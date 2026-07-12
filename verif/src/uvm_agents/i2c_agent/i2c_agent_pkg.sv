package i2c_agent_pkg;

import uvm_pkg::*;

`include "uvm_macros.svh"


`include "i2c_pl_seq_item.svh"
`include "i2c_ll_seq_item.svh"
`include "i2c_agent_config.svh"
`include "i2c_pl_monitor.svh"
`include "i2c_ll_sequencer.svh"
`include "i2c_pl_sequencer.svh"
`include "i2c_l2p_sequence.svh"
`include "i2c_driver.svh"
`include "i2c_agent.svh"



/** This task shall be used to send data of `DATA_SIZE` length into DUT bit by bit
  * while simultaneously having choice to trigger `rst_n`
  * Example:
	  data_buffer[DATA_SIZE-1:0] = 8'b11110011
	  rst_buffer[DATA_SIZE-1:0]  = 8'b11110111
	  									  ^
										rst_n

	meaning -> send 11110011 && on 5th bit pull rst_n to 1'b0
  */
/*task resetSequence(logic[ADDR_SIZE-1:0] addr,
				   logic[WORD_SIZE-1:0] data_buffer,
			       logic[WORD_SIZE-1:0] rst_buffer = 0-1);

	
	automatic i2c_pl_seq_item pl_frame = new;
	pl_frame.dummy(addr);

	for (int i = 0; i < WORD_SIZE; i++) begin
		if (i==0) 
			pl_frame.startbit = 1'b1;
		pl_frame.stopbit = (i==WORD_SIZE-1) ? 1'b1 : 1'b0;
		pl_frame.ack = 1'b1;

		if (rst_buffer[i] == 1'b0) begin
			start_item(pl_frame);
			finish_item(pl_frame);

			pl_frame.dummy(addr);
			pl_frame.rst_n = 1'b0;
			pl_frame.data = '{data_buffer[i]};

			start_item(pl_frame);
			finish_item(pl_frame);

			pl_frame.dummy(addr);
		end
		else begin
			pl_frame.data = {pl_frame.data, data_buffer[i]};
		end
	end


	start_item(pl_frame);
	finish_item(pl_frame);

endtask: resetSequence*/

endpackage: i2c_agent_pkg
