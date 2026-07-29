

class clk_agent_config#(parameter int CLK_COUNT = 1) extends uvm_object;

    `uvm_object_utils(clk_agent_config)

    bit ACTIVE = 1;

    virtual clk_if#(.CLK_COUNT(CLK_COUNT)) sline;

    function new(string name = "clk_agent_config");
        super.new(name);
    endfunction

endclass: clk_agent_config
