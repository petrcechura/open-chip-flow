import uvm_pkg::*;
import i2c_agent_pkg::*;
import clk_agent_pkg::*;

class i2c_slave_core_env extends uvm_component;

    `uvm_component_utils(i2c_slave_core_env)

    localparam CLK_COUNT = 1;
    
    i2c_agent m_i2c_agent;
    i2c_agent_config m_i2c_agent_config;

    clk_agent#(.CLK_COUNT(CLK_COUNT)) m_clk_agent;
    clk_agent_config#(.CLK_COUNT(CLK_COUNT)) m_clk_agent_config;

    
    extern function new(string name = "i2c_slave_core_env", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass

function i2c_slave_core_env::new(string name = "i2c_slave_core_env", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void i2c_slave_core_env::build_phase(uvm_phase phase);

    // instantiate I2C agent & its config
    // ----------------------------------
    m_i2c_agent = i2c_agent::type_id::create("m_i2c_agent", this);
    m_i2c_agent_config = i2c_agent_config::type_id::create("m_i2c_agent_config", this);

    // instantiate clk agent & its config
    // ----------------------------------
    m_clk_agent = clk_agent#(.CLK_COUNT(CLK_COUNT))::type_id::create("m_clk_agent", this);
    m_clk_agent_config = clk_agent_config#(.CLK_COUNT(CLK_COUNT))::type_id::create("m_clk_agent_config", this);


    // Assign interface from global 
    // config to local cfg.sline
    // ---------------------------- 
    if (uvm_config_db#(virtual i2c_if)::exists(null, "uvm_test_top", "i2c_ifc")) begin
        uvm_config_db#(virtual i2c_if)::get(null, 
                                        "uvm_test_top",
                                        "i2c_ifc",
                                        m_i2c_agent_config.sline);
    end
    else begin
        `uvm_fatal("build_phase", "Unable to find I2C interface in the uvm_config_db");
    end

    if (uvm_config_db#(virtual clk_if)::exists(null, "uvm_test_top", "clk_ifc")) begin
        uvm_config_db#(virtual clk_if)::get(null, 
                                        "uvm_test_top",
                                        "clk_ifc",
                                        m_clk_agent_config.sline);
    end
    else begin
        `uvm_fatal("build_phase", "Unable to find CLK interface in the uvm_config_db");
    end

    // store i2c_agent & its config to config_db
    // -----------------------------------------
    m_i2c_agent.m_i2c_agent_config = m_i2c_agent_config;
    uvm_config_db#(i2c_agent_config)::set(null, "i2c_slave_core", "i2c_agent_config", m_i2c_agent.m_i2c_agent_config);

    // store clk_agent & its config to config_db
    // -----------------------------------------
    m_clk_agent.m_clk_agent_config = m_clk_agent_config;
    uvm_config_db#(clk_agent_config)::set(null, "i2c_slave_core", "clk_agent_config", m_clk_agent.m_clk_agent_config);

endfunction: build_phase

// TODO
function void i2c_slave_core_env::connect_phase(uvm_phase phase);

endfunction: connect_phase
