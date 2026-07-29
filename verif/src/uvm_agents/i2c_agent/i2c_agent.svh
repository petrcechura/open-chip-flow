class i2c_agent extends uvm_agent;
              

    `uvm_component_utils(i2c_agent)

    uvm_analysis_port #(i2c_seq_item) ap;

    i2c_driver m_i2c_driver;

    /* sequencers */
    i2c_sequencer m_i2c_sequencer;

    /* monitors */
    //i2c_monitor m_i2c_monitor;

    /* configuration */
    i2c_agent_config m_i2c_agent_config;


    function new(string name = "i2c_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        ap = new("I2C Monitor", this);
  
        if (m_i2c_agent_config == null) begin
            `uvm_fatal("build_phase", "i2c_agent_config instance found NULL! It is expected it's set in parent environment...");
        end

        if(m_i2c_agent_config.ACTIVE) begin
            m_i2c_driver = i2c_driver::type_id::create("m_i2c_driver", this);
            m_i2c_sequencer = i2c_sequencer::type_id::create("m_i2c_sequencer", this);
        end
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);

        if(m_i2c_agent_config.ACTIVE) begin
            m_i2c_driver.seq_item_port.connect(m_i2c_sequencer.seq_item_export);

            if (m_i2c_agent_config.sline) begin
                m_i2c_driver.sline = m_i2c_agent_config.sline;
            end else begin
                `uvm_fatal("connect_phase", "Virtual i2c interface not found in I2C agent config!");
            end 

        end

    endfunction: connect_phase

    task run_phase(uvm_phase phase);

    endtask: run_phase

endclass: i2c_agent
