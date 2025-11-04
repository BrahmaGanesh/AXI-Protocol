class axi_agent extends uvm_agent;
    `uvm_component_utils(axi_agent)

    axi_driver drv;
    axi_monitor mon;
    axi_sequencer seqr;

    virtual axi_interface vif;
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    function new(string name="axi_agent",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual axi_interface)::get(this,"","vif",vif))
            `uvm_fatal("AGENT", "No interface found for axi_agent")
        
        mon = axi_monitor::type_id::create("mon",this);

        if(is_active == UVM_ACTIVE) begin
            drv = axi_driver::type_id::create("drv",this);
            seqr = axi_sequencer::type_id::create("seqr",this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        uvm_config_db#(virtual axi_interface)::set(this, "mon", "vif", vif);
        if(is_active == UVM_ACTIVE) begin
            uvm_config_db#(virtual axi_interface)::set(this, "drv", "vif", vif);
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction
endclass
