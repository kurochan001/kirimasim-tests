/*
:name: test_class_inheritance_virtual_super
:description: Class inheritance, super, and virtual method overriding (IEEE 1800-2023 Sections 8.13, 8.15 and 8.20)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.13 8.15 8.20
:oracle: spec
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_inheritance_virtual_super.expected
*/
// Class inheritance, super, and virtual method overriding
// (IEEE 1800-2023 Sections 8.13, 8.15 and 8.20)

module test_class_inheritance_virtual_super;
    // Base class
    class Transaction;
        bit [31:0] addr;
        bit [31:0] data;
        int id;

        function new(int id_val = 0);
            this.id = id_val;
            this.addr = 32'h0;
            this.data = 32'h0;
        endfunction

        virtual function void display();
            $display("Transaction[%0d]: addr=0x%08x, data=0x%08x", id, addr, data);
        endfunction

        virtual function string get_type();
            return "Transaction";
        endfunction
    endclass

    // Derived class
    class BurstTransaction extends Transaction;
        int burst_length;
        bit [1:0] burst_type;

        function new(int id_val = 0, int len = 1);
            super.new(id_val);  // Call parent constructor
            this.burst_length = len;
            this.burst_type = 2'b00;
        endfunction

        // Override display method
        virtual function void display();
            super.display();  // Call parent method
            $display("  Burst: length=%0d, type=%0d", burst_length, burst_type);
        endfunction

        // Override get_type method
        virtual function string get_type();
            return "BurstTransaction";
        endfunction

        // New method specific to derived class
        function void set_burst_params(int len, bit [1:0] btype);
            burst_length = len;
            burst_type = btype;
        endfunction
    endclass

    initial begin
        Transaction tr;
        BurstTransaction burst_tr;

        // Create base class object
        tr = new(1);
        tr.addr = 32'h1000;
        tr.data = 32'hDEADBEEF;

        // Create derived class object
        burst_tr = new(2, 4);
        burst_tr.addr = 32'h2000;
        burst_tr.data = 32'hCAFEBABE;
        burst_tr.set_burst_params(8, 2'b10);

        // Test polymorphism
        $display("=== Direct calls ===");
        tr.display();
        burst_tr.display();

        // Test virtual method calls through base class handle
        $display("\n=== Polymorphic calls ===");
        tr = burst_tr;  // Base class handle to derived object
        $display("Type: %s", tr.get_type());
        tr.display();

        // A virtual method called through a base class handle runs the
        // override of the object's class (8.20).
        if (tr.get_type() == "BurstTransaction") begin
            $display("\nTest passed");
            $display("PASS");
        end else begin
            $display("\nTest failed: get_type() = %s", tr.get_type());
            $display("FAIL");
        end
    end
endmodule
