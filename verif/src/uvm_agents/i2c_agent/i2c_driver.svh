class i2c_driver extends uvm_driver #(i2c_pl_seq_item);

    `uvm_component_utils(i2c_driver)
    
    function new(string name = "i2c_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    virtual i2c_if sline;
    
    i2c_pl_seq_item pkt;
    
    bit clk;
    
    
    // data sent from MSB to LSB
    task send_pkts;
    
    fork
        begin 
            if (pkt.startbit === 1'b1) begin
                    sline.sda = 1'b0;
                    bitPeriod(0.25);
                    sline.scl = 1'b0;
            end
    
            foreach(pkt.data[i]) begin
                fork
                    // SDA
                    begin
    					if (pkt.data[i] === 1'b1 || pkt.data[i] === 1'bZ) begin
                        	bitPeriod(0.25);
    						sline.sda = 1'bZ;
    					end
    					else begin
                        	bitPeriod(0.25);
    						sline.sda = 1'b0;
    					end
                    end
                    // SCL
                    begin
                        sline.scl = 1'b0;
                        bitPeriod(0.5);
                        sline.scl = 1'bZ;
                        bitPeriod(0.5);
                    end
                join
            end
            
            /* sample ACK bit to seq_item */
            if (pkt.ack === 1'b1) begin
                sline.sda = 1'bZ;
                sline.scl = 1'b0;
                bitPeriod(0.5);
                pkt.ack = (sline.sda_w === 1'b0) ? 1'b0 : 1'b1;
                sline.scl = 1'bZ;
                bitPeriod(0.5);
            end
                
            if (pkt.stopbit === 1'b1) begin
                fork
                    begin
                        sline.sda = 1'b0;
                        bitPeriod(0.5);
                        sline.sda = 1'bZ;
                    end
    
                    begin
                        sline.scl = 1'b0;
                        bitPeriod(0.25);
                        sline.scl = 1'bZ;
                    end
                join
            end
        end
        
        // ADDR
        begin
            /* this cond. makes addr remain still in wave diagram when not changed */
            if ( {sline.addr} !== {pkt.addr} ) begin
                sline.addr = { >> {pkt.addr} };
            end
        end
    
    	// RST_N
    	begin
    		if ( sline.rst_n !== pkt.rst_n ) begin
    			sline.rst_n = pkt.rst_n;
    		end
    	end
    join
    
    endtask: send_pkts
    
    task bitPeriod(real length = 1);
      begin
        repeat(pkt.scl_period * length)
          @(posedge sline.clk);
      end
    endtask: bitPeriod
    
    task run_phase(uvm_phase phase);
      integer bitPtr = 0;
      begin
        sline.sda = 1'bZ;
        sline.scl = 1'bZ;
        sline.rst_n = 1'b1;
    
        forever
          begin
            seq_item_port.get_next_item(pkt);
    
    
            // Variable delay
            repeat(pkt.delay) begin
                @(posedge sline.clk);
            end
    
            send_pkts;
    
            seq_item_port.item_done();
          end
        end
    endtask: run_phase

endclass: i2c_driver
