

class i2c_agent_config extends uvm_object;

    `uvm_object_utils(i2c_agent_config)

    bit ACTIVE = 1;

    virtual i2c_if sline;

    function new(string name = "i2c_agent_config");
        super.new(name);
    endfunction

endclass: i2c_agent_config
