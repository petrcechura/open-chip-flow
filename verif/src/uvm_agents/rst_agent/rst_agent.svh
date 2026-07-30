class rst_agent#(parameter int RST_COUNT = 1) extends uvm_agent;
              
    `uvm_component_utils(rst_agent)

    uvm_analysis_port #(rst_seq_item) ap;

    rst_driver#(.RST_COUNT(RST_COUNT)) m_rst_driver;

    /* sequencers */
    rst_sequencer m_rst_sequencer;

    /* configuration */
    rst_agent_config#(.RST_COUNT(RST_COUNT)) m_rst_agent_config;

    /** Changes the active level of a reset (logic value that is set when reset is requested) */
    function set_active_level(int unsigned _type, bit level);
        if (_type >= RST_COUNT) begin
            `uvm_fatal("build_phase", "Cannot set active reset level, value not within bounds!")
        end

        uvm_config_db#(bit)::set(null, "rst_agent", $sformatf("active_level_%d", _type), level);
    endfunction

    function new(string name = "rst_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
  
        if (m_rst_agent_config == null) begin
            `uvm_fatal("build_phase", "rst_agent_config instance found NULL! It is expected it's set in parent environment...");
        end

        m_rst_driver = rst_driver#(.RST_COUNT(RST_COUNT))::type_id::create("m_rst_driver", this);
        m_rst_sequencer = rst_sequencer::type_id::create("m_rst_sequencer", this);

        uvm_config_db#(rst_sequencer)::set(null, "rst_agent", "sequencer", m_rst_sequencer);

    endfunction: build_phase

    function void connect_phase(uvm_phase phase);

        m_rst_driver.seq_item_port.connect(m_rst_sequencer.seq_item_export);
        
        if (m_rst_agent_config.sline) begin
            m_rst_driver.sline = m_rst_agent_config.sline;
        end else begin
            `uvm_fatal("connect_phase", "Virtual CLK interface not found in CLK agent config!");
        end 

    endfunction: connect_phase

    task run_phase(uvm_phase phase);

    endtask: run_phase

endclass: rst_agent
