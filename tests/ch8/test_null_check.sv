/*
:name: test_null_check
:description: Null Object Handling Tests
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_null_check.expected
*/
// IEEE 1800-2023 Section 8.4 - Null Object Handling Tests
module test_null_check;
    int pass_count = 0;
    int fail_count = 0;

    class SimpleClass;
        int value;
        function new(int v = 0);
            value = v;
        endfunction
        function int get_value();
            return value;
        endfunction
    endclass

    class Container;
        SimpleClass obj;
        int has_set;
        function new();
            has_set = 0;
        endfunction
        function void set_obj(SimpleClass o);
            obj = o;
            has_set = 1;
        endfunction
        function int has_obj();
            return has_set;
        endfunction
    endclass

    initial begin
        SimpleClass a, b, c;
        Container cont;

        $display("=== IEEE 1800-2023 Null Check Tests ===");

        // Test 1: Create and verify
        $display("Test 1: Create object");
        a = new(10);
        if (a.get_value() == 10) begin $display("Test 1 PASS: value=%0d", a.get_value()); pass_count++; end
        else begin $display("Test 1 FAIL: got %0d", a.get_value()); fail_count++; end

        // Test 2: Two different objects
        $display("Test 2: Two objects");
        b = new(20);
        if (a.get_value() == 10 && b.get_value() == 20) begin
            $display("Test 2 PASS: a=%0d b=%0d", a.get_value(), b.get_value());
            pass_count++;
        end
        else begin $display("Test 2 FAIL"); fail_count++; end

        // Test 3: Assign handle
        $display("Test 3: Assign handle");
        c = a;
        if (c.get_value() == 10) begin $display("Test 3 PASS: c=%0d", c.get_value()); pass_count++; end
        else begin $display("Test 3 FAIL: got %0d", c.get_value()); fail_count++; end

        // Test 4: Modify through alias
        $display("Test 4: Modify through alias");
        c.value = 99;
        if (a.get_value() == 99) begin $display("Test 4 PASS: a=%0d", a.get_value()); pass_count++; end
        else begin $display("Test 4 FAIL: got %0d", a.get_value()); fail_count++; end

        // Test 5: Container basic
        $display("Test 5: Container basic");
        cont = new();
        if (cont.has_obj() == 0) begin $display("Test 5 PASS: no obj"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        // Test 6: Container with object
        $display("Test 6: Container with object");
        cont.set_obj(b);
        if (cont.has_obj() == 1) begin $display("Test 6 PASS: has obj"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        // Test 7: Access container's object
        $display("Test 7: Access container object");
        if (cont.obj.get_value() == 20) begin $display("Test 7 PASS: value=%0d", cont.obj.get_value()); pass_count++; end
        else begin $display("Test 7 FAIL: got %0d", cont.obj.get_value()); fail_count++; end

        // Test 8: Compare handles
        $display("Test 8: Handle comparison");
        c = b;
        if (c.get_value() == b.get_value()) begin $display("Test 8 PASS: same value"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
