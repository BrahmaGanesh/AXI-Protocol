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
        axi_transaction wr_tr;
        forever begin
            tr=new();
            @(posedge vif.clk);
            if(vif.awvalid && vif.awready)begin
                wr_tr = axi_transaction::type_id::create("wr_tr",this);
                wr_tr.awaddr = vif.awaddr;
                wr_tr.wr_en =1;
            end
            if(vif.wvalid && vif.wready && wr_tr !=null)begin
                wr_tr.wdata = vif.wdata;
                mon_ap.write(wr_tr);
                `uvm_info("MON", $sformatf("WRITE Addr=0x%0h Data=0x%0h", wr_tr.awaddr, wr_tr.wdata), UVM_LOW)
                wr_tr = null;
            end
            if(vif.arvalid && vif.arready) begin
                tr = axi_transaction::type_id::create("rd_tr",this);
                tr.araddr = vif.araddr;
                tr.wr_en = 0;
            end
            if(vif.rvalid && vif.rready && tr != null) begin
                tr.rdata = vif.rdata;
                mon_ap.write(tr);
                `uvm_info("MON", $sformatf("READ Addr=0x%0h Data=0x%0h", tr.araddr, tr.rdata), UVM_LOW)
                tr = null;
            end
        end
    endtask
endclass