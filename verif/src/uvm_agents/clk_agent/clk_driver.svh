class clk_driver#(parameter int CLK_COUNT = 1) extends uvm_driver #(clk_seq_item);

    `uvm_component_utils(clk_driver)
    
    function new(string name = "clk_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    virtual clk_if sline;
    
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

        clk_enables[seq_item.clk_type] = seq_item.clk_en;
        clk_periods[seq_item.clk_type] = seq_item.clk_period;
    endfunction
    
    task run_phase(uvm_phase phase);
        integer bitPtr = 0;

        begin

            $display("AAA");
            // Set all clocks to 0s
            for (int i = 0; i < CLK_COUNT; i++) begin
                clk_periods[i] = 20ns;
                sline.clk[i] = 1'b0;
                clk_loop(i);
            end
            $display("BBB");

            forever begin
                $display("DDD");
                seq_item_port.get_next_item(seq_item);
                $display("CCC");
                clk_modify;
                $display("EEE");
    
                seq_item_port.item_done();
            end
        end
    endtask: run_phase

endclass: clk_driver
