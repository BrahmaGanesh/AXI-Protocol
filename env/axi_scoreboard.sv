class axi_scoreboard extends uvm_component;
  `uvm_component_utils(axi_scoreboard)

  uvm_analysis_imp #(axi_transaction, axi_scoreboard) analysis_export;
  virtual axi_interface vif;
  bit [31:0] mem [128];
  bit [31:0] rdata, wdata;

  function new(string name = "axi_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_export = new("analysis_export", this);
    if (!uvm_config_db#(virtual axi_interface)::get(this, "", "vif", vif))
      `uvm_info("[SCO]", "Scoreboard interface not found", UVM_MEDIUM);
  endfunction

  virtual function void write(axi_transaction tr);
    if (vif.rst_n == 1'b0) begin
      foreach (mem[i]) mem[i] = 0;
      `uvm_info("[SCO]", "Scoreboard reset done", UVM_LOW);
    end
    else if (tr.wvalid && tr.wready) begin
      mem[tr.awaddr]     = tr.wdata[7:0];
      mem[tr.awaddr + 1] = tr.wdata[15:8];
      mem[tr.awaddr + 2] = tr.wdata[23:16];
      mem[tr.awaddr + 3] = tr.wdata[31:24];
      `uvm_info("[SCO]", $sformatf("WRITE: addr=%0h data=%0h", tr.awaddr, tr.wdata), UVM_LOW);
    end
    else if (tr.rvalid && tr.rready) begin
      rdata = {mem[tr.araddr + 3], mem[tr.araddr + 2], mem[tr.araddr + 1], mem[tr.araddr]};
      if (tr.rdata === rdata)begin
        `uvm_info("[SCO]", $sformatf("READ PASS: addr=%0h data=%0h", tr.araddr, rdata), UVM_LOW);
      end
      else
        `uvm_error("[SCO]", $sformatf("READ FAIL: addr=%0h exp=%0h got=%0h", tr.araddr, rdata, tr.rdata));
    end
  endfunction
endclass
