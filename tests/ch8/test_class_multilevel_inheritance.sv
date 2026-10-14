/*
:name: test_class_multilevel_inheritance
:description: Multilevel inheritance; constructors that do not call super.new() explicitly (IEEE 1800-2023 Sections 8.13 and 8.17)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.13 8.17
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_multilevel_inheritance.expected
*/
// IEEE 1800-2023 Sections 8.13 and 8.17 - Multilevel inheritance; constructors that do not call super.new() explicitly
module test_class_multilevel_inheritance;
    int pass_count = 0;
    int fail_count = 0;

    class Base;
        int value;

        function new(int v = 0);
            value = v;
        endfunction

        function int get_value();
            return value;
        endfunction

        function void set_value(int v);
            value = v;
        endfunction

        function int compute();
            return value * 2;
        endfunction
    endclass

    class Derived extends Base;
        int extra;

        function new(int v = 0, int e = 0);
            value = v;  // super.new() is called implicitly first (8.17)
            extra = e;
        endfunction

        function int get_total();
            return value + extra;
        endfunction

        function void set_both(int v, int e);
            value = v;
            extra = e;
        endfunction

        function int double_extra();
            return extra * 2;
        endfunction
    endclass

    class TripleClass extends Derived;
        int third;

        function new(int v = 0, int e = 0, int t = 0);
            value = v;
            extra = e;
            third = t;
        endfunction

        function int sum_all();
            return value + extra + third;
        endfunction
    endclass

    initial begin
        Base b;
        Derived d;
        TripleClass t;

        $display("=== IEEE 1800-2023 this/super Keywords Tests ===");

        // Test 1: Base class basic
        $display("Test 1: Base class");
        b = new(10);
        if (b.get_value() == 10) begin $display("Test 1 PASS: value=%0d", b.get_value()); pass_count++; end
        else begin $display("Test 1 FAIL: got %0d", b.get_value()); fail_count++; end

        // Test 2: Base compute
        $display("Test 2: Base compute");
        if (b.compute() == 20) begin $display("Test 2 PASS: compute=%0d", b.compute()); pass_count++; end
        else begin $display("Test 2 FAIL: got %0d", b.compute()); fail_count++; end

        // Test 3: Derived constructor
        $display("Test 3: Derived constructor");
        d = new(20, 5);
        if (d.value == 20 && d.extra == 5) begin
            $display("Test 3 PASS: value=%0d extra=%0d", d.value, d.extra);
            pass_count++;
        end
        else begin $display("Test 3 FAIL"); fail_count++; end

        // Test 4: Derived get_total
        $display("Test 4: Derived get_total");
        if (d.get_total() == 25) begin $display("Test 4 PASS: total=%0d", d.get_total()); pass_count++; end
        else begin $display("Test 4 FAIL: got %0d", d.get_total()); fail_count++; end

        // Test 5: Inherited method
        $display("Test 5: Inherited method");
        if (d.get_value() == 20) begin $display("Test 5 PASS: value=%0d", d.get_value()); pass_count++; end
        else begin $display("Test 5 FAIL: got %0d", d.get_value()); fail_count++; end

        // Test 6: Inherited compute
        $display("Test 6: Inherited compute");
        if (d.compute() == 40) begin $display("Test 6 PASS: compute=%0d", d.compute()); pass_count++; end
        else begin $display("Test 6 FAIL: got %0d", d.compute()); fail_count++; end

        // Test 7: Triple inheritance
        $display("Test 7: Triple inheritance");
        t = new(10, 20, 30);
        if (t.sum_all() == 60) begin $display("Test 7 PASS: sum=%0d", t.sum_all()); pass_count++; end
        else begin $display("Test 7 FAIL: got %0d", t.sum_all()); fail_count++; end

        // Test 8: Triple access inherited
        $display("Test 8: Triple access inherited");
        if (t.get_total() == 30 && t.compute() == 20) begin
            $display("Test 8 PASS: total=%0d compute=%0d", t.get_total(), t.compute());
            pass_count++;
        end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
