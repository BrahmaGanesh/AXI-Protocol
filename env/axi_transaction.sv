class axi_transaction extends uvm_sequence_item;

    rand bit [31:0] awaddr;
    rand bit [7:0] awlen;
    rand bit [2:0] awsize;
    rand bit [1:0] awburst;
    bit       awvalid;
    bit       awready;
    bit       awid;
    
    rand bit [31:0] wdata;
    rand bit [3:0] wstrb;
         bit       wid;
         bit       wvalid;
         bit       wready;
         bit       wlast;
    
    rand bit [31:0] araddr;
    rand bit [7:0] arlen;
    rand bit [2:0] arsize;
    rand bit [1:0] arburst;
         bit       arid;
    bit [31:0] rdata;
    bit        rid;

    bit [1:0] bresp;
    bit [1:0] rresp;
    bit       rlast;
    bit       wlast;
    bit       id;

    rand bit  wr_en;

    constraint ids {awid == id; wid == id; bid == id; arid == id; rid == id;}

    `uvm_object_utils(axi_transaction)

    function new(string name="axi_transaction");
        super.new(name);
    endfunction
endclass