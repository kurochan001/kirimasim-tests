/*
:name: test_class_method_calls
:description: Class Method Tests
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_method_calls.expected
*/
// IEEE 1800-2023 Section 8.6 - Class Method Tests
module test_class_method_calls;
    int pass_count = 0;
    int fail_count = 0;

    class Counter;
        int value;

        function new();
            value = 0;
        endfunction

        function void add(int v);
            value = value + v;
        endfunction

        function void mult(int v);
            value = value * v;
        endfunction

        function int get_val();
            return value;
        endfunction

        function void reset();
            value = 0;
        endfunction
    endclass

    initial begin
        Counter c;
        int result;

        $display("=== IEEE 1800-2023 Class Method Tests ===");

        $display("Test 1: Create counter");
        c = new();
        if (c.value == 0) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", c.value); fail_count++; end

        $display("Test 2: Single add");
        c.add(5);
        if (c.value == 5) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", c.value); fail_count++; end

        $display("Test 3: Multiple adds");
        c.reset();
        c.add(3);
        c.add(4);
        if (c.value == 7) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", c.value); fail_count++; end

        $display("Test 4: Add and mult");
        c.reset();
        c.add(5);
        c.mult(2);
        if (c.value == 10) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", c.value); fail_count++; end

        $display("Test 5: Triple add");
        c.reset();
        c.add(1);
        c.add(2);
        c.add(3);
        if (c.value == 6) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", c.value); fail_count++; end

        $display("Test 6: Mixed ops");
        c.reset();
        c.add(2);
        c.mult(3);
        c.add(4);
        if (c.value == 10) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", c.value); fail_count++; end

        $display("Test 7: Get value");
        c.reset();
        c.add(10);
        result = c.get_val();
        if (result == 10) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        $display("Test 8: Verify reset");
        c.reset();
        if (c.value == 0) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", c.value); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
