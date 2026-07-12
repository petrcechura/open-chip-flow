/*

** PHYSICAL LAYER ** 

This seq_item serves as a lowest layer of communication. The user can define presence of `startbit` and `stopbit` and, of course, `data`. If some of parameters are null (data) or 1'b0 (sb), they're not present.
    
    -------------------------->
    |(STARTBIT)|DATA|(STOPBIT)|
    -------------------------->

seq_item is designed to be able to combine multiple instances into one fully customable word.
For example: Two seq_items, one with startbit, other with stopbit, should provide fully functional i2c_word

*/

class i2c_pl_seq_item extends uvm_sequence_item;

`uvm_object_utils(i2c_pl_seq_item)

localparam int ADDR_SIZE = 7;
// This param is used only for data randomization (data can be of any length)
localparam int WORD_SIZE = 8;

/* Seq_item properties */
rand int delay;
rand logic data[];
rand bit startbit;
rand bit stopbit;
rand bit[ADDR_SIZE-1:0] addr;
rand int scl_period;
rand bit rst_n;
rand bit ack;

/* Randomization contraints */
constraint data_size_c { data.size() inside {[(WORD_SIZE/2):(WORD_SIZE*2)]}; };
constraint delay_c { delay >= 12; delay <= 200; };
constraint scl_period_c { scl_period == 200; };

/* pre-set the seq_item into default values that do not trigger any action on a driver */
function void dummy(bit[ADDR_SIZE-1:0] addr, int scl_period = 100);
    this.data = '{};
    this.startbit = 1'b0;
    this.stopbit = 1'b0;
    this.ack = 1'b0;
    this.delay = 0;
	this.addr = addr;
	this.scl_period = scl_period;
	this.rst_n = 1'b1;
endfunction: dummy

/* Standard UVM Methods */
extern function new(string name = "i2c_pl_seq_item");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
extern function string convert2string();
extern function void do_print(uvm_printer printer);
extern function void do_record(uvm_recorder recorder);


endclass: i2c_pl_seq_item

function i2c_pl_seq_item::new(string name = "i2c_pl_seq_item");
  super.new(name);
endfunction


function void i2c_pl_seq_item::do_copy(uvm_object rhs);
  i2c_pl_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  delay = rhs_.delay;
  startbit = rhs_.startbit;
  stopbit = rhs_.stopbit;
  data = rhs_.data;
  scl_period = rhs_.scl_period;
  //rst_n = rhs_.rst_n;
  addr = rhs_.addr;

endfunction:do_copy

function bit i2c_pl_seq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
  i2c_pl_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  return super.do_compare(rhs, comparer) &&
         delay == rhs_.delay &&
         startbit == rhs_.startbit &&
         stopbit == rhs_.stopbit &&
         data == rhs_.data &&
         scl_period == rhs_.scl_period &&
         //rst_n == rhs_.rst_n &&
         addr == rhs_.addr;

endfunction:do_compare

function string i2c_pl_seq_item::convert2string();
  string s;

  $sformat(s, "%s\n", super.convert2string());
  // Convert to string function reusing s:
  $sformat(s, "%s\n delay\t%0d\n startbit\t%0b\n stopbit\t%0d\n data\t%p\naddr\t%8b\n", s, delay, startbit, stopbit, data, addr);
  //$sformat(s, "%s\n scl_period\t%0b\n rst_n\t%0h\n", s, scl_period, rst_n);
  return s;

endfunction:convert2string

function void i2c_pl_seq_item::do_print(uvm_printer printer);
  if(printer.knobs.sprint == 0) begin
    $display(convert2string());
  end
  else begin
    printer.m_string = convert2string();
  end
endfunction:do_print

function void i2c_pl_seq_item:: do_record(uvm_recorder recorder);
  super.do_record(recorder);

  // Use the record macros to record the item fields:
  `uvm_record_field("delay", delay)
  `uvm_record_field("startbit", startbit)
  `uvm_record_field("stopbit", stopbit)
  `uvm_record_field("data", data)
  `uvm_record_field("addr", addr)
  //`uvm_record_field("rst_n", rst_n)
  `uvm_record_field("scl_period", scl_period)

endfunction:do_record

