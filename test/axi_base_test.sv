class axi_base_test extends uvm_test;
    `uvm_component_utils(axi_base_test)

    axi_env env;
    axi_agent m_agent;
    axi_sequence m_seq;

    function new(string name="axi_base_test",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env=axi_env::type_id::create("env",this);
      m_seq= axi_sequence::type_id::create("m_seq");
    endfunction

   virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    m_seq.start(env.agent.seqr);
    phase.drop_objection(this);
  endtask
endclass