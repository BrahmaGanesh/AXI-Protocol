`include "uvm_macros.svh"
import uvm_pkg::*;
`include "axi_interface.sv"
`include "axi_pkg.sv"

module top;
    import axi_pkg::*;
    axi_interface vif();
    axi_slave #(.ADDR_WIDTH(32),.DATA_WIDTH(32)) DUT(.intf(vif));

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
      run_test("axi_fixed_test");
    end

    assign vif.next_addr_wr = DUT.nextaddr_next;
    assign vif.next_addr_rd = DUT.rdnextaddr;
endmodule