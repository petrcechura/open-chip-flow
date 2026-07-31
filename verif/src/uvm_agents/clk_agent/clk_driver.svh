class clk_driver#(parameter int CLK_COUNT = 1) extends uvm_driver #(clk_seq_item);

    `uvm_component_utils(clk_driver)
    
    function new(string name = "clk_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    virtual clk_if#(.CLK_COUNT(CLK_COUNT)) sline;
    
    clk_seq_item seq_item;
    
    bit[CLK_COUNT-1:0] clk_enables;
    realtime clk_periods[CLK_COUNT];

    task clk_loop(int unsigned clk_type);
        fork
            forever begin
                if (clk_type >= CLK_COUNT) begin
                    `uvm_fatal("run_phase", "An attempt to set up a clock out of interface bounds!")
                end

                if (clk_enables[clk_type] == 1'b1)  begin
                    sline.clk[clk_type] = ~sline.clk[clk_type];
                end

                #(clk_periods[clk_type]/2);
            end
        join_none
    endtask

    function clk_modify;
        if (seq_item.clk_type >= CLK_COUNT) begin
            `uvm_fatal("run_phase", "An attempt to set up a clock out of interface bounds!")
        end
        
        if (seq_item.clk_period_set) begin
            `uvm_info("datalink", $sformatf("CLK: Clock (%0d) set to %0t ns", seq_item.clk_type, seq_item.clk_period), UVM_MEDIUM);
            clk_periods[seq_item.clk_type] = seq_item.clk_period;
        end
        else begin 
            `uvm_info("datalink", $sformatf("CLK: Clock (%0d) turned %s", seq_item.clk_type, (seq_item.clk_en ? "on" : "off")), UVM_MEDIUM);
            clk_enables[seq_item.clk_type] = seq_item.clk_en;
        end
    endfunction
    
    task run_phase(uvm_phase phase);
        integer bitPtr = 0;

        begin

            // Set all clocks to 0s
            for (int i = 0; i < CLK_COUNT; i++) begin
                clk_periods[i] = 20ns;
                sline.clk[i] = 1'b0;
                clk_loop(i);
            end

            forever begin
                seq_item_port.get_next_item(seq_item);
                clk_modify;
    
                seq_item_port.item_done();
            end
        end
    endtask: run_phase

endclass: clk_driver
