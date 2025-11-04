class axi_sequence extends uvm_sequence #(axi_transaction);
    `uvm_object_utils(axi_sequence)

    function new(string name="axi_sequence");
        super.new(name);
    endfunction

    virtual task body();
    endtask
endclass