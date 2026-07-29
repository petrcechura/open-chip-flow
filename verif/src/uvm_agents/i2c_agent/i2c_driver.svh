class i2c_driver extends uvm_driver #(i2c_seq_item);

    `uvm_component_utils(i2c_driver)
    
    function new(string name = "i2c_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    virtual i2c_if sline;
    
    i2c_seq_item packets;
    
    bit clk;
    
    
    // data sent from MSB to LSB
    task send_packets;
    
        foreach(packets.data[i]) begin

            fork
                begin
                    // Start bit 
                    sline.sda = 1'b0;
                    bitPeriod(0.25);
                    sline.scl = 1'b0;

                    // Data
                    foreach(packets.data[i][j]) begin
                        fork
                            // SDA
                            begin
            					if (packets.data[i][j] === 1'b1 || packets.data[i][j] === 1'bZ) begin
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
                    if (packets.ack === 1'b1) begin
                        sline.sda = 1'bZ;
                        sline.scl = 1'b0;
                        bitPeriod(0.5);

                        // NACK
                        if (sline.sda_w != 1'b0) begin
                            
                            // TODO simple break causes internal cpp error
                            //break;
                        end

                        sline.scl = 1'bZ;
                        bitPeriod(0.5);
                    end

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

                // ADDR
                begin
                    /* this cond. makes addr remain still in wave diagram when not changed */
                    if ( {sline.addr} !== {packets.addr} ) begin
                        sline.addr = packets.addr;
                    end
                end
            
            	// RST_N
            	begin
            		if ( sline.rst_n !== packets.rst_n ) begin
            			sline.rst_n = packets.rst_n;
            		end
            	end
            join

        end
    
    endtask: send_packets
    
    task bitPeriod(real length = 1);
        begin
            repeat(packets.scl_period * length)
                @(posedge sline.clk);
        end
    endtask: bitPeriod
    
    task run_phase(uvm_phase phase);
        integer bitPtr = 0;

        if (sline == null) begin
            `uvm_fatal("run_phase", "virtual interface `sline` not set in i2c_driver! Cannot proceed...");
        end

        begin
            $display("dasdsadsa");
            sline.sda = 1'bZ;
            sline.scl = 1'bZ;
            sline.rst_n = 1'b1;
    
            forever begin
                seq_item_port.get_next_item(packets);
    
                // Variable delay
                repeat(packets.delay) begin
                    @(posedge sline.clk);
                end
    
                send_packets;
    
                seq_item_port.item_done();
            end
        end
    endtask: run_phase

endclass: i2c_driver
