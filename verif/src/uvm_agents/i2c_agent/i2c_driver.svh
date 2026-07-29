class i2c_driver extends uvm_driver #(i2c_seq_item);

    `uvm_component_utils(i2c_driver)
    
    function new(string name = "i2c_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    virtual i2c_if sline;
    
    i2c_seq_item packets;
    
    // data sent from MSB to LSB
    task send_packets;
        `uvm_info("run_phase", "i2c_driver sending packets", UVM_LOW);

        sline.sda_en = 1'b1;
        sline.sda_i = 1'b0;
        #1ns;
        sline.sda_i = 1'b1;
        #1ns;
        sline.sda_i = 1'b0;
        #1ns;
        sline.sda_i = 1'b1;
        sline.sda_en = 1'b0;

        foreach(packets.data[i]) begin

            fork
                begin
                    sline.sda_en = 1'b1;
                    sline.scl_en = 1'b1;

                    // Start bit 
                    sline.sda_i = 1'b0;
                    $display("before");
                    bitPeriod(0.25);
                    $display("after");
                    sline.scl_i = 1'b0;

                    // Data
                    foreach(packets.data[i][j]) begin
                        fork
                            // SDA
                            begin
            					if (packets.data[i][j] === 1'b1) begin
                                	bitPeriod(0.25);
            						sline.sda_i = 1'b1;
            					end
            					else begin
                                	bitPeriod(0.25);
            						sline.sda_i = 1'b0;
            					end
                            end
                            // SCL
                            begin
                                sline.scl_i = 1'b0;
                                bitPeriod(0.5);
                                sline.scl_i = 1'b1;
                                bitPeriod(0.5);
                            end
                        join
                    end

                    /* sample ACK bit to seq_item */
                    if (packets.ack === 1'b1) begin
                        sline.sda_en = 1'b0;
                        sline.scl_i = 1'b0;
                        bitPeriod(0.5);

                        // NACK
                        if (sline.sda_o != 1'b0) begin
                            
                            // TODO simple break causes internal cpp error
                            //break;

                        end

                        sline.scl_i = 1'b1;
                        bitPeriod(0.5);
                        sline.sda_en = 1'b0;
                    end

                    fork
                        begin
                            sline.sda_i = 1'b0;
                            bitPeriod(0.5);
                            sline.sda_i = 1'b1;
                        end
                    
                        begin
                            sline.scl_i = 1'b0;
                            bitPeriod(0.25);
                            sline.scl_i = 1'b1;
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

        `uvm_info("run_phase", "i2c_driver running", UVM_LOW);
        begin

            sline.sda_en = 1'b0;
            sline.scl_en = 1'b0;
            sline.sda_i = 1'b1;
            sline.scl_i = 1'b1;
    
            forever begin
                seq_item_port.get_next_item(packets);
                `uvm_info("run_phase", "i2c_driver got new item", UVM_LOW);
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
