class axi_driver extends uvm_driver;
    `uvm_component_utils(axi_driver)

    virtual axi_interface vif;
    axi_transaction tr;

    function new(string name="axi_driver",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual axi_interface)::get(this,"","vif",vif))
            `uvm_fatal("DRV","axi_interface is not set")
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(tr);
            if(tr.wr_en)begin
                vif.awvalid <= 1;
                vif.awaddr <= tr.awaddr;
                @(posedge vif.clk);
                wait(vif.awready);
                vif.awvalid <= 0;

                vif.wdata <= tr.wdata;
                vif.wvalid <= 1;
                @(posedge vif.clk);
                wait(vif.wready);
                vif.wvalid <= 0;
            end
            else begin
                vif.araddr <= tr.araddr;
                vif.arvalid <= 1;
                @(posedge vif.clk);
                wait(vif.arready);
                vif.arvalid <= 0;
            end
            seq_item_port.item_done();
        end
    endtask
endclass
