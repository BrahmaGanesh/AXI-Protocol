class axi_driver extends uvm_driver #(axi_transaction);
    `uvm_component_utils(axi_driver)

    virtual axi_interface vif;
    axi_transaction tr;

    function new(string name="axi_driver",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
        if(!uvm_config_db#(virtual axi_interface)::get(this,"","vif",vif))
            `uvm_fatal("DRV","axi_interface is not set")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(tr);
          		run();
            seq_item_port.item_done();
        end
    endtask
      task run();
        if(vif.rst_n==1'b0) reset_task();
        else if(tr.awburst==2'b00) fixed_trans();
        else if(tr.awburst==2'b01) incr_trans();
        else if(tr.awburst==2'b10) wrap_trans();
        else if(tr.awburst==2'b11) error_trans();
      endtask
      task reset_task();
        vif.rst_n <= 1'b0;
        vif.awaddr <= 1'b0;
        vif.awvalid <= 1'b0;
        vif.awid <= 1'b0;
        vif.awsize <= 1'b0;
        vif.awburst <= 1'b0;
        vif.awlen  <= 1'b0;
        vif.wid <= 1'b0;
        vif.wstrb <= 1'b0;
        vif.wlast <= 1'b0
        vif.wdata <= 1'b0;
        vif.wvalid <= 1'b0;
        vif.bid <= 1'b0;
        vif.araddr <= 1'b0;
        vif.arvalid <= 1'b0;
        vif.arid <= 1'b0;
        vif.arsize <= 1'b0;
        vif.arburst <= 1'b0;
        vif.arlen  <= 1'b0;
        vif.rid <= 1'b0;
      endtask
      task fixed_trans();
        fixed_wr();
        fixed_rd();
      endtask
      task fixed_wr();
        `uvm_info(get_type_name(),"Starting FIXED write transaction",UVM_MEDIUM);
        @(posedge vif.clk);
        vif.rst_n <= 1'b1;
        vif.awvalid <= 1'b1;
        vif.awaddr <= tr.awaddr;
        vif.awid <= tr.id;
        vif.awburst <=tr.awburst;
        vif.awsize <= tr.awsize;
        vif.awlen <= tr.awlen;
        
        vif.wvalid <= 0;
        vif.bready <= 0;
        vif.arvalid <= 0;
        vif.rready <= 0;
        
        wait(vif.awready == 1'b1);
        @(posedge vif.clk);
        vif.awvalid <= 0;
        vif.wvalid <= 1;
        vif.wid <= tr.id;
        vif.wlast <= 0;
        wait(vif.wready == 1'b1);
        @(posedge vif.clk);
        for(int i=0; i<tr.awlen; i++)begin
          vif.wdata <= $urandom_range(0,10);
          vif.wstrb <= 4'b1111;
          
          wait(vif.wready == 1'b1);
          @(posedge vif.clk);
        end
        vif.wlast <= 1;
        vif.wvalid <= 0;
        vif.bready <= 1;
        vif.bid <= tr.awid;
        @(posedge vif.clk);
        wait(vif.bvalid == 1'b1);
        vif.bready <= 1'b0;
        `uvm_info(get_type_name(),"Completed FIXED write transaction",UVM_MEDIUM);   
      endtask
      task fixed_rd();
        `uvm_info(get_type_name(),"Starting FIXED Read transaction",UVM_MEDIUM);
        @(posedge vif.clk);
        vif.rst_n <= 1'b1;
        vif.arvalid <= 1'b1;
        vif.araddr <= tr.awaddr;
        vif.arburst <= tr.awburst;
        vif.arlen <= tr.awlen;
        vif.arsize <= tr.awsize;
        wait(vif.arready == 1'b1);
        vif.rready <= 1'b1;
        wait(vif.rlast == 1'b1);
        vif.arvalid <= 1'b0;
        vif.rready <= 1'b1;
        `uvm_info(get_type_name(),"Completed FIXED Read transaction",UVM_MEDIUM);
      endtask
endclass
