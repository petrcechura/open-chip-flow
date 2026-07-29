

class rst_agent_config#(parameter int RST_COUNT = 1) extends uvm_object;

    `uvm_object_utils(rst_agent_config)

    bit ACTIVE = 1;

    virtual rst_if#(.RST_COUNT(RST_COUNT)) sline;

    function new(string name = "rst_agent_config");
        super.new(name);
    endfunction

endclass: rst_agent_config
