`include "axi_interface.sv"
`include "axi_pkg.sv"

module top;
    import axi_pkg::*;
    axi_interface #(32,32,4) vif();
    axi_slave #(.ADDR_WIDTH(32),.DATA_WIDTH(8)) DUT(.intf(vif));

    initial begin
        vif.clk = 0;
        forever #5 vif.clk =~vif.clk;
    end

    initial begin
        vif.rst_n = 0;
        #20;
        vif.rst_n = 1;
    end
    initial begin
        $dumpfile("axi_wave.vcd");
        $dumpvars(0,top);
    end
    initial begin
        uvm_config_db#(virtual axi_interface)::set(null,"*","vif",vif);
        run_test("axi_base_test");
    end
endmodule