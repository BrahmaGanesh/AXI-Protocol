interface axi_interface #(parameter ADDR_WIDTH=32,DATA_WIDTH=8,ID_WIDTH=4);
    logic       clk;
    logic       rst_n;


    logic [ADDR_WIDTH -1 :0] awaddr;
    logic [7:0] awlen;
    logic [2:0] awsize;
    logic [1:0] awburst;
    logic       awvalid;
    logic       awready;
    logic [ ID_WIDTH - 1:0] awid;
    
    logic [DATA_WIDTH -1 :0] wdata;
    logic [3:0] wstrb;
    logic       wlast;
    logic       wvalid;
    logic       wready;
    logic       wid;
    
    logic [ID_WIDTH - 1:0] bid;
    logic [1:0] bresp;
    logic       bvalid;
    logic       bready;
    
    logic [ID_WIDTH - 1:0]  arid;
    logic [ADDR_WIDTH - 1:0] araddr;
    logic [7:0] arlen;
    logic [2:0] arsize;
    logic [1:0] arburst;
    logic       arvalid;
    logic       arready;
    
    logic [ID_WIDTH -1 :0]  rid;
    logic [DATA_WIDTH - 1:0] rdata;
    logic       rlast;
    logic       rvalid;
    logic       rready;
    logic [1:0] rresp;
  
  logic [3:0] next_addr_wr;
  logic [3:0] next_addr_rd;
endinterface