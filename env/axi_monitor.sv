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
            tr=new();
            @(posedge vif.clk);
            if(vif.awvalid && vif.awready)begin
                tr.awaddr = vif.awaddr;
                tr.wr_en =1;
            end
            if(vif.wvalid && vif.wready)begin
                tr.wdata = vif.wdata;
                mon_ap.write(tr);
            end
            if(vif.arvalid && vif.arready) begin
                tr.araddr = vif.araddr;
                tr.wr_en = 0;
            end
            if(vif.rvalid && vif.rready) begin
                tr.rdata = vif.rdata;
                mon_ap.write(tr);
            end
        end
    endtask
endclass