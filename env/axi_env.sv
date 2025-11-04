class axi_env extends uvm_env;
    `uvm_component_utils(axi_env);

    axi_agent agent;
    axi_scoreboard soc;
    axi_coverage cov;

    function new(string name="axi_agent",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent = axi_agent::type_id::create("agent",this);
        soc = axi_scoreboard::type_id::create("soc",this);
        cov = axi_coverage::type_id::create("cov",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.mon_ap.connect(soc.analysis_export);
        agent.mon,mon_ap.connect(cov.analysis_export);
    endfunction
endclass