class axi_transaction extends uvm_sequence_item;

    rand bit [31:0] awaddr;
    rand bit [7:0] awlen;
    rand bit [2:0] awsize;
    rand bit [1:0] awburst;
    bit       awvalid;
    bit       awready;
    
    rand bit [31:0] wdata;
    rand bit [3:0] wstrb;
    
    rand bit [31:0] araddr;
    rand bit [7:0] arlen;
    rand bit [2:0] arsize;
    rand bit [1:0] arburst;
    bit [31:0] rdata;

    bit [1:0] bresp;
    bit [1:0] rresp;
    bit       rlast;
    bit       wlast;

    rand bit  wr_en;

    `uvm_object_utils(axi_transaction)

    function new(string name="axi_transaction");
        super.new(name);
    endfunction
endclass