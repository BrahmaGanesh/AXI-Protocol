calss axi_trans extends sequence_item;

    rand logic [31:0] awaddr;
    rand logic [7:0] awlen;
    rand logic [2:0] awsize;
    rand logic [1:0] awburst;
    logic       awvalid;
    logic       awready;
    
    rand logic [31:0] wdata;
    rand logic [3:0] wstrb;
    
    rand logic [31:0] araddr;
    rand logic [7:0] arlen;
    rand logic [2:0] arsize;
    rand logic [1:0] arburst;

    logic [1:0] bresp;
    logic [1:0] rresp;
    logic       rlast;
    logic       wlast;

    `uvm_object_utils(axi_trans)

    function new(string name="axi_trans");
        super.new(name);
    endfunction
endclass