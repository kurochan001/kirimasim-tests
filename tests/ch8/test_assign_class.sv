/*
:name: test_assign_class
:description: Test for class assignment
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.12 8.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_class.expected
*/
// Test for class assignment
// IEEE 1800-2023 §8.8: Object assignment
module test_assign_class;
    class Item;
        int value;
        function new(int v);
            value = v;
        endfunction
    endclass

    initial begin
        Item a, b, c;

        // Create object
        a = new(100);
        if (a.value != 100) $display("FAIL: Initial value");

        // Reference assignment (shallow copy)
        b = a;
        b.value = 200;
        if (a.value != 200) $display("FAIL: Reference assignment");

        // New object
        c = new(300);
        a = c;
        if (a.value != 300) $display("FAIL: New object assign");

        // Null assignment
        c = null;
        if (c != null) $display("FAIL: Null assign");

        // Check a still valid
        if (a.value != 300) $display("FAIL: a still valid");

        $display("PASS: Class assignment");
        $finish;
    end
endmodule
