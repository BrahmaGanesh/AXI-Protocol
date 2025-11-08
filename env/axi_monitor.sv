class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)

    virtual axi_interface vif;
    uvm_analysis_port  #(axi_transaction) mon_ap;
    axi_transaction tr;

    function new(string name="axi_monitor",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual axi_interface)::get(this,"","vif",vif))
            `uvm_fatal("MON","monitor axi_interface not get")
        mon_ap = new("mon_ap",this);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
         @(posedge vif.clk);
         run();
        end
    endtask

    task run();
        if(vif.rst_n == 1'b0) reset_task();
        else if((vif.rst_n == 1'b1) && (vif.awaddr < 128) || (vif.araddr < 128)) valid_wr_rd();
        else if((vif.rst_n == 1'b1) && (vif.awaddr > 127) || (vif.araddr > 127)) error_wr_rd();
    endtask

    task reset_task();
        tr=axi_transaction::type_id::create("tr");
        tr.awaddr = vif.awaddr;
        tr.awvalid = vif.awvalid;
        tr.awburst = vif.awburst;
        tr.awready = vif.awready;
        tr.awsize = vif.awsize;
        tr.awid = vif.awid;
        tr.awlen  = vif.awlen;
        tr.wid = vif.wid;
        tr.wdata = vif.wdata;
        tr.wstrb = vif.wstrb;
        tr.wlast = vif.wlast;
        tr.wvalid = vif.wvalid;
        tr.wready = vif.wready;
        tr.arid = vif.arid;
        tr.araddr = vif.araddr;
        tr.arburst = vif.arburst;
        tr.arvalid = vif.arvalid;
        tr.arready = vif.arready;
        tr.arlen = vif.arlen;
        tr.arsize = vif.arsize;
        tr.rvalid = vif.rvalid;
        tr.rready = vif.rready;
        tr.rid = vif.rid;
        tr.rlast = 1'b0;
        tr.rresp = 1'b0;
        tr.rdata = 1'b0;
        mon_ap.write(tr);
    endtask
    task valid_wr_rd();
        tr=axi_transaction::type_id::create("tr");
        if((vif.awvalid == 1'b1)&&(vif.awready == 1'b1))begin
            `uvm_info(get_type_name(),"inside write address transaction",UVM_MEDIUM);
            tr.awaddr = vif.awaddr;
            tr.awvalid = vif.awvalid;
            tr.awburst = vif.awburst;
            tr.awready = vif.awready;
            tr.awsize = vif.awsize;
            tr.awid = vif.awid;
            tr.awlen  = vif.awlen;
            end
        else if((vif.wvalid == 1'b1) && (vif.wready == 1'b1))begin
           `uvm_info(get_type_name(),"inside write data transaction",UVM_MEDIUM); 
           tr.wid = vif.wid;
            tr.wdata = vif.wdata;
            tr.wstrb = vif.wstrb;
            tr.wlast = vif.wlast;
            tr.wvalid = vif.wvalid;
            tr.wready = vif.wready;
            end
        else if((vif.bvalid == 1'b1) && (vif.bready == 1'b1))begin
            `uvm_info(get_type_name(),"inside responce transaction",UVM_MEDIUM);
            tr.bid = vif.bid;
            tr.bresp = vif.bresp;
            tr.bvalid = vif.bvalid;
            tr.bready = vif.bready;
            end
        else if((vif.arvalid == 1'b1) && (vif.arready == 1'b1))begin
            `uvm_info(get_type_name(),"inside read address transaction",UVM_MEDIUM);
             tr.arid = vif.arid;
            tr.araddr = vif.araddr;
            tr.arburst = vif.arburst;
            tr.arvalid = vif.arvalid;
            tr.arready = vif.arready;
            tr.arlen = vif.arlen;
            tr.arsize = vif.arsize;
            end
        esle if((vif.rready == 1'b1) && (vif.rvalid == 1'b1))begin
            `uvm_info(get_type_name(),"inside read data transaction",UVM_MEDIUM);
            tr.rvalid = vif.rvalid;
            tr.rready = vif.rready;
            tr.rid = vif.rid;
            tr.rlast = vif.rlast;
            tr.rresp = vif.rresp;
            tr.rdata = vif.rdata;
            end
            mon_ap.write(tr)
    endtask
    task error_wr_rd();
    endtask
endclass