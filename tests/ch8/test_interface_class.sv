/*
:name: test_interface_class
:description: Interface class implemented by two classes, called through an interface class handle
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_class.expected
*/
`timescale 1ns/1ps

interface class ifc_base;
    pure virtual function int get_id();
    pure virtual function void set_id(int id);
endclass

class impl_a implements ifc_base;
    int id;

    virtual function int get_id();
        return id;
    endfunction

    virtual function void set_id(int id);
        this.id = id;
    endfunction
endclass

class impl_b implements ifc_base;
    int id;

    virtual function int get_id();
        return id * 2;
    endfunction

    virtual function void set_id(int id);
        this.id = id;
    endfunction
endclass

module test_interface_class;
    int fails = 0;

    initial begin
        impl_a a;
        impl_b b;
        ifc_base base_ref;

        a = new();
        b = new();

        // Test through concrete type
        a.set_id(10);
        if (a.get_id() != 10) begin fails++; $display("FAIL: impl_a"); end

        b.set_id(10);
        if (b.get_id() != 20) begin fails++; $display("FAIL: impl_b"); end

        // Test through interface reference
        base_ref = a;
        if (base_ref.get_id() != 10) begin fails++; $display("FAIL: interface ref a"); end

        base_ref = b;
        if (base_ref.get_id() != 20) begin fails++; $display("FAIL: interface ref b"); end

        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
