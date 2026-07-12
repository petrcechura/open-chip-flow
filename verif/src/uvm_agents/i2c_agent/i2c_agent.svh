class i2c_agent extends uvm_agent;
              

  `uvm_component_utils(i2c_agent)
                             

  uvm_analysis_port #(i2c_ll_seq_item) ap;


  i2c_driver m_i2c_driver;

  /* sequencers */
  i2c_ll_sequencer m_i2c_ll_sequencer;
  i2c_pl_sequencer m_i2c_pl_sequencer;

  /* monitors */
  i2c_pl_monitor m_i2c_pl_monitor;

  /* translator sequences */
  i2c_l2p_sequence m_i2c_l2p_sequence;

  /* configuration */
  i2c_agent_config cfg;


  function new(string name = "i2c_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    ap = new("I2C Monitor", this);

    m_i2c_pl_monitor = i2c_pl_monitor::type_id::create("m_i2c_pl_monitor", this);

    if (!uvm_config_db #(i2c_agent_config)::get(this, "", "i2c_agent_config", cfg) )
     `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration i2c_agent_config from uvm_config_db. Have you set() it?")
  
 
 //if(cfg.ACTIVE)
    if(1)
      begin
        m_i2c_driver = i2c_driver::type_id::create("m_i2c_driver", this);
        m_i2c_ll_sequencer = i2c_ll_sequencer::type_id::create("m_i2c_ll_sequencer", this);
        m_i2c_pl_sequencer = i2c_pl_sequencer::type_id::create("m_i2c_pl_sequencer", this);
        m_i2c_l2p_sequence = i2c_l2p_sequence::type_id::create("m_i2c_l2p_sequence", this);
      end
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);

    //if(cfg.ACTIVE)
    if(1) begin
      m_i2c_driver.seq_item_port.connect(m_i2c_pl_sequencer.seq_item_export);
      m_i2c_driver.sline = cfg.sline;

      m_i2c_l2p_sequence.ll_sequencer = m_i2c_ll_sequencer;
    end


    m_i2c_pl_monitor.sline = cfg.sline;

  endfunction: connect_phase

  task run_phase(uvm_phase phase);
  
      /* translate ll_seq_items into pl_sequencer via translator l2p sequence*/
      fork
          m_i2c_l2p_sequence.start(m_i2c_pl_sequencer);
      join_none
  endtask: run_phase

endclass: i2c_agent
