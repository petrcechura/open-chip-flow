
/*
	LINK LAYER

*/

// forward decl.
typedef class i2c_pl_seq_item;

class i2c_ll_seq_item extends uvm_sequence_item;

`uvm_object_utils(i2c_ll_seq_item)

localparam int ADDR_SIZE = 7;
localparam int WORD_SIZE = 8;

/* Seq_item properties */
rand logic[WORD_SIZE-1:0] data[];
rand bit[ADDR_SIZE-1:0] addr;
rand int scl_period;
rand int delay;

// user has option to assign low-level item for some specific purposes (i.e. reset)
rand i2c_pl_seq_item pl_item;

function void reset(bit[ADDR_SIZE-1:0] addr, int clk_count = 10);
	this.pl_item = new;
	this.pl_item.data = '{1'b1};
	this.pl_item.rst_n = 1'b0;
	this.pl_item.startbit = 1'b0;
	this.pl_item.stopbit = 1'b0;
	this.pl_item.addr = addr;
	this.pl_item.ack = 1'b0;
	this.pl_item.delay = 0;
	this.pl_item.scl_period = clk_count;
endfunction: reset

/* Randomization contraints */
constraint scl_period_c { scl_period == 100; };
constraint pl_item_c { pl_item == null; };
constraint data_c { data.size() > 0; data.size() < 10; };
constraint delay_c { delay > 0; delay < 100; };

/* Standard UVM Methods */
extern function new(string name = "i2c_ll_seq_item");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
extern function string convert2string();
extern function void do_print(uvm_printer printer);
extern function void do_record(uvm_recorder recorder);


endclass: i2c_ll_seq_item

function i2c_ll_seq_item::new(string name = "i2c_ll_seq_item");
  super.new(name);
endfunction


function void i2c_ll_seq_item::do_copy(uvm_object rhs);
  i2c_ll_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  data = rhs_.data;
  //TODO

endfunction:do_copy

function bit i2c_ll_seq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
  i2c_ll_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  return super.do_compare(rhs, comparer) &&
         data == rhs_.data;

endfunction:do_compare

function string i2c_ll_seq_item::convert2string();
  string s;

  /*$sformat(s, "%s\n", super.convert2string());
  // Convert to string function reusing s:
  $sformat(s, "%s\n delay\t%0d\n startbit\t%0b\n stopbit\t%0d\n data\t%p\naddr\t%8b\n", s, delay, startbit, stopbit, data, addr);
  $sformat(s, "%s\n scl_period\t%0b\n rst_n\t%0h\n", s, scl_period, rst_n);*/
  return s;

endfunction:convert2string

function void i2c_ll_seq_item::do_print(uvm_printer printer);
  if(printer.knobs.sprint == 0) begin
    $display(convert2string());
  end
  else begin
    printer.m_string = convert2string();
  end
endfunction:do_print

function void i2c_ll_seq_item:: do_record(uvm_recorder recorder);
  super.do_record(recorder);

  // Use the record macros to record the item fields:
  //`uvm_record_field("delay", delay)

endfunction:do_record

