class clk_agent#(parameter int CLK_COUNT = 1) extends uvm_agent;
              

    `uvm_component_utils(clk_agent)

    uvm_analysis_port #(clk_seq_item) ap;

    clk_driver#(.CLK_COUNT(CLK_COUNT)) m_clk_driver;

    /* sequencers */
    clk_sequencer m_clk_sequencer;

    /* configuration */
    clk_agent_config#(.CLK_COUNT(CLK_COUNT)) m_clk_agent_config;


    function new(string name = "clk_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
  
        if (m_clk_agent_config == null) begin
            `uvm_fatal("build_phase", "clk_agent_config instance found NULL! It is expected it's set in parent environment...");
        end

        m_clk_driver = clk_driver#(.CLK_COUNT(CLK_COUNT))::type_id::create("m_clk_driver", this);
        m_clk_sequencer = clk_sequencer::type_id::create("m_clk_sequencer", this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);

        m_clk_driver.seq_item_port.connect(m_clk_sequencer.seq_item_export);
        
        if (m_clk_agent_config.sline) begin
            m_clk_driver.sline = m_clk_agent_config.sline;
        end else begin
            `uvm_fatal("connect_phase", "Virtual i2c interface not found in I2C agent config!");
        end 

    endfunction: connect_phase

    task run_phase(uvm_phase phase);

    endtask: run_phase

endclass: clk_agent
