class axi_coverage extends uvm_subscriber #(axi_transaction);
    `uvm_component_utils(axi_coverage)

    covergroup axi_cg;
        coverpoint tr.awaddr {
            bins low_addr  = {[0:15]};
            bins high_addr = {[240:255]};
        }
        coverpoint tr.awburst {
            bins fixed  = {0};
            bins incr   = {1};
            bins wrap   = {2};
        }

        coverpoint tr.araddr {
            bins low_addr  = {[0:15]};
            bins high_addr = {[240:255]};
        }
        coverpoint tr.arburst {
            bins fixed  = {0};
            bins incr   = {1};
            bins wrap   = {2};
        }

        cross tr.awburst, tr.arburst;
    endgroup

    axi_transaction tr;

    function new(string name = "axi_coverage", uvm_component parent = null);
        super.new(name, parent);
        axi_cg = new();
    endfunction

    virtual function void write(axi_transaction t);
        tr = t;
        axi_cg.sample();
        `uvm_info("AXI_COV", "Sampled coverage for transaction", UVM_LOW)
    endfunction
endclass
