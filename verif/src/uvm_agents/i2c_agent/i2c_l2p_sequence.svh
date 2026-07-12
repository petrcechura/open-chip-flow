
class i2c_l2p_sequence extends uvm_sequence #(i2c_pl_seq_item);

`uvm_object_utils(i2c_l2p_sequence)

uvm_sequencer #(i2c_ll_seq_item) ll_sequencer;

function new(string name = "i2c_l2p_sequence");
    super.new(name);
endfunction

virtual function void build_phase(uvm_phase phase);

endfunction: build_phase

task body;

    i2c_ll_seq_item ll_item = i2c_ll_seq_item::type_id::create("ll_item");
	i2c_pl_seq_item pl_item = i2c_pl_seq_item::type_id::create("pl_item");
	automatic bit rw = 1'b0; // WRITE = 0; READ = 1

    forever begin
        ll_sequencer.get_next_item(ll_item);

		// if the physical-layer item is present, it is sent with priority, ignoring all other ll properties
		if (ll_item.pl_item != null) begin
			pl_item = ll_item.pl_item;
			start_item(pl_item);
			finish_item(pl_item);
			ll_item.pl_item = null;
		end
		
		else begin: rw_begin
			foreach (ll_item.data[i]) begin
                	automatic i2c_pl_seq_item pl_item = i2c_pl_seq_item::type_id::create("pl_item");

					// READ ( the 8'bZZZZZZZZZ is considered as READ request)
					if ($size(ll_item.data[i]) == $countbits(ll_item.data[i], 1'bZ)) begin
                    	pl_item.dummy(ll_item.addr, ll_item.scl_period);
                		pl_item.data = { >> {ll_item.data[i]}};
						

						start_item(pl_item);
						finish_item(pl_item);
						
						// on the last frame, send NACK and do a STOPBIT
						if (i==ll_item.data.size()-1) begin
							pl_item.dummy(ll_item.addr, ll_item.scl_period);
							pl_item.data = '{1'b1};
							pl_item.stopbit = 1'b1;

							start_item(pl_item);
							finish_item(pl_item);
						end
						// ACK every data
						else begin
							pl_item.dummy(ll_item.addr, ll_item.scl_period);
							pl_item.data = '{1'b0};

							start_item(pl_item);
							finish_item(pl_item);
						end
						
					end
					
					// WRITE
					else begin
                    	pl_item.dummy(ll_item.addr, ll_item.scl_period);

                		pl_item.startbit = (i==0) ? 1'b1 : 1'b0;
                		pl_item.stopbit = (i==ll_item.data.size()-1) ? 1'b1 : 1'b0;

                		pl_item.data = { >> {ll_item.data[i]} };
                		pl_item.addr = ll_item.addr;
                		pl_item.delay = ll_item.delay;
                		pl_item.scl_period = ll_item.scl_period;
                		pl_item.ack = 1'b1;
						
                		start_item(pl_item);
                		finish_item(pl_item);

                		// if the ACK is received, send a stopbit and quit transmitting
                		if (pl_item.ack == 1'b1) begin

                    		automatic i2c_pl_seq_item pl_item = i2c_pl_seq_item::type_id::create("pl_item");
                    		pl_item.dummy(ll_item.addr, ll_item.scl_period);
                    		pl_item.stopbit = 1'b1;
                    		start_item(pl_item);
                    		finish_item(pl_item);

                    		`uvm_error("", $sformatf("unit NACKed the %0d. data (%p)", i, ll_item.data[i]));
                    		break; 
                		end
					end
				end // end foreach
		end: rw_begin

        ll_sequencer.item_done();
	end	// end forever

endtask

endclass : i2c_l2p_sequence
