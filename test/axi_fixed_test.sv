class axi_fixed_sequence extends uvm_sequence #(axi_transaction);
  `uvm_object_utils(axi_fixed_sequence)

  function new(string name = "axi_fixed_sequence");
    super.new(name);
  endfunction

  virtual task body();
    axi_transaction tr;
    #40;
    tr = axi_transaction::type_id::create("tr");
    start_item(tr);
    if (!tr.randomize() with {
      tr.awaddr  == 8'h55;
      tr.awburst == 2'b00;
      tr.awlen   == 4'b1111;
    }) begin
      `uvm_error("SEQ", "Randomization failed for axi_transaction")
    end
    finish_item(tr);
  endtask
endclass

class axi_fixed_test extends axi_base_test;
  `uvm_component_utils(axi_fixed_test)

  axi_fixed_sequence f_seq;

  function new(string name = "axi_fixed_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    f_seq = axi_fixed_sequence::type_id::create("f_seq");
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    f_seq.start(env.agent.seqr);
    phase.drop_objection(this);
  endtask
endclass
