interface axi_interface;
    logic       clk;
    logic       rst_n;

    logic [31:0] awaddr;
    logic [7:0] awlen;
    logic [2:0] awsize;
    logic [1:0] awburst;
    logic       awvalid;
    logic       awready;
    
    logic [31:0] wdata;
    logic [3:0] wstrb;
    logic       wlast;
    logic       wvalid;
    logic       wready;
    
    logic [1:0] bresp;
    logic       bvalid;
    logic       bready;
    
    logic [31:0] araddr;
    logic [7:0] arlen;
    logic [2:0] arsize;
    logic [1:0] arburst;
    logic       arvalid;
    logic       arready;
    
    logic [31:0] rdata;
    logic       rlast;
    logic       rvalid;
    logic       rready;
    logic [1:0] rresp;

    modport master (
    input  awready, wready, bresp, bvalid, arready, rdata, rvalid, rresp,
    output awaddr, awlen, awsize, awburst, awvalid,
           wdata, wstrb, wlast, wvalid, bready,
           araddr, arlen, arsize, arburst, arvalid, rready
    );
    
    modport slave (
    input  awaddr, awlen, awsize, awburst, awvalid,
           wdata, wstrb, wlast, wvalid, bready,
           araddr, arlen, arsize, arburst, arvalid, rready,
    output awready, wready, bresp, bvalid, arready, rdata, rvalid, rresp
    );
    
endinterface