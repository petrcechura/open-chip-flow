class i2c_driver extends uvm_driver #(i2c_seq_item);

    `uvm_component_utils(i2c_driver)
    
    function new(string name = "i2c_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    virtual i2c_if sline;
    
    i2c_seq_item packets;
    
    // data sent from MSB to LSB
    task send_packets;
        automatic bit cont = 1'b1;

        // Drive the I2C bus
        sline.sda_en = 1'b1;
        sline.scl_en = 1'b1;

        // Start bit 
        `uvm_info("datalink", "I2C: Startbit", UVM_MEDIUM);
        sline.sda_o = 1'b0;
        bitPeriod(0.25);
        sline.scl_o = 1'b0;

        // Send all data sequently
        foreach(packets.data[i]) begin

            if (!cont) begin
                break; 
            end

            fork
                begin

                    // Data
                    `uvm_info("datalink", $sformatf("I2C: Sending %0d. frame [%b]", i, packets.data[i]), UVM_MEDIUM);
                    foreach(packets.data[i][j]) begin
                        fork
                            // SDA
                            begin
            					if (packets.data[i][j] === 1'b1) begin
                                	bitPeriod(0.25);
            						sline.sda_o = 1'b1;
            					end
            					else begin
                                	bitPeriod(0.25);
            						sline.sda_o = 1'b0;
            					end
                            end
                            // SCL
                            begin
                                sline.scl_o = 1'b0;
                                bitPeriod(0.5);
                                sline.scl_o = 1'b1;
                                bitPeriod(0.5);
                            end
                        join
                    end

                    // ACK / NACK
                    // ----------
                    `uvm_info("datalink", "I2C: Waiting for acknowledge...", UVM_MEDIUM);
                    if (packets.ack === 1'b1) begin
                        sline.sda_en = 1'b0;
                        sline.scl_o = 1'b0;
                        bitPeriod(0.5);

                        if (sline.sda_i === 1'b0) begin
                            `uvm_info("datalink", "I2C: ACK sampled", UVM_MEDIUM);
                        end else begin
                            `uvm_info("datalink", "I2C: NACK sampled", UVM_MEDIUM);
                            cont = 1'b0;
                        end

                        sline.scl_o = 1'b1;
                        bitPeriod(0.5);
                        sline.sda_o = 1'b0;
                        sline.sda_en = 1'b1;
                    end
                    
                end

                // ADDR
                begin
                    /* this cond. makes addr remain still in wave diagram when not changed */
                    if ( {sline.addr} !== {packets.addr} ) begin
                        sline.addr = packets.addr;
                    end
                end

            join

        end

        // Stopbit
        `uvm_info("datalink", "I2C: Stopbit", UVM_MEDIUM);
        fork
            begin
                sline.sda_o = 1'b0;
                bitPeriod(0.5);
                sline.sda_o = 1'b1;
            end
        
            begin
                sline.scl_o = 1'b0;
                bitPeriod(0.25);
                sline.scl_o = 1'b1;
            end
        join
    
    endtask: send_packets
    
    task bitPeriod(real length = 1);
        begin
            repeat(packets.scl_period * length) begin
                @(posedge sline.clk);
            end
        end
    endtask: bitPeriod
    
    task run_phase(uvm_phase phase);
        integer bitPtr = 0;

        begin

            sline.sda_en = 1'b0;
            sline.scl_en = 1'b0;
            sline.sda_o = 1'b1;
            sline.scl_o = 1'b1;
    
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
