/**
 * Default OPEN-CHIP-FLOW Report Server aims to provide unified way throughout the OCF framework
 * for messages printed via `uvm_*` reporting macros, since original UVM report server
 * provides mostly reduntant info makes the log unreadable.
 *
 * For standard reporting macros following applies:
 *   - `uvm_(warning/error/fatal): As much information as possible is printed (line, file, time...)
 *   - `uvm_info`: This macro shall be used to track current state of verification, where "id" field
 *     categories messages based on communication layers they come from.
 *
 * Communcation layers for `uvm_info` are as follows:
 *   - "physical": 
 *      - single events about one or multiple signals in single timestamp
 *      - i.e. rising/falling edge of a signal/group of signals 
 *   - "datalink":
 *      - low-level transitions of bytes with no context of their representation
 *      - i.e. sending 1010 over i2c...
 *   - "command":
 *      - multiple transitions of bytes with their meaning described
 *      - i.e. sending i2c command
 *   - "application"
 *      - sequences of commands with indent described
 *      - i.e. writing to XY register
*/
class ocf_report_server extends uvm_report_server;

    `uvm_object_utils(ocf_report_server)

    virtual function string compose_message(uvm_severity severity,
                                     string name,
                                     string id, 
                                     string message,
                                     string filename,
                                     int line);
 
        uvm_severity_type sv; 
        string fname;
        string indent;

        if ( id == "physical" ) begin
            indent = "......[PHY]";
        end else if ( id == "datalink" ) begin
            indent = "....[DLK]";
        end else if ( id == "command" ) begin
            indent = "..[HVL]";
        end else if ( id == "application") begin
            indent = "[APP]";
        end
     
        fname = shrink(filename);
        sv = uvm_severity_type'(severity);
        
        if (severity == UVM_INFO) begin
            return $sformatf("%8t ns %s: %s", $realtime, indent, message);
        end
        else begin
            return $sformatf("%8t ns <%9s>: %s @ (%s, %3d)", $realtime, sv.name(), message, fname, line);
        end

 
    endfunction: compose_message
 
    protected function string shrink(string txt);
        automatic string tail;
 
        foreach(txt[i]) begin
            if (txt[i] == "/") begin
                tail = ""; 
            end
            else begin
                tail = {tail, string'(txt[i])};
            end
        end
 
        return tail;
    endfunction: shrink
 
 
endclass: ocf_report_server