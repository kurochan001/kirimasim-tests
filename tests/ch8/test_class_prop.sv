/*
:name: test_class_prop
:description: Class Property Tests
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.5 8.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_prop.expected
*/
// IEEE 1800-2023 Sections 8.5 and 8.7 - Class Property Tests
module test_class_prop;
    int pass_count = 0;
    int fail_count = 0;

    class Counter;
        int value;
        int step;

        function new(int init_val = 0, int init_step = 1);
            value = init_val;
            step = init_step;
        endfunction

        function void increment();
            value = value + step;
        endfunction

        function int get_value();
            return value;
        endfunction
    endclass

    initial begin
        Counter c1, c2;

        $display("=== IEEE 1800-2023 Class Property Tests ===");

        $display("Test 1: Default construct");
        c1 = new();
        if (c1.value == 0 && c1.step == 1) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        $display("Test 2: Param construct");
        c2 = new(10, 2);
        if (c2.value == 10 && c2.step == 2) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        $display("Test 3: Increment");
        c1.increment();
        if (c1.value == 1) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", c1.value); fail_count++; end

        $display("Test 4: Step 2");
        c2.increment();
        if (c2.value == 12) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", c2.value); fail_count++; end

        $display("Test 5: Get value");
        if (c1.get_value() == 1) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        $display("Test 6: Multi incr");
        c1.increment();
        c1.increment();
        if (c1.value == 3) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", c1.value); fail_count++; end

        $display("Test 7: Direct set");
        c1.value = 100;
        if (c1.value == 100) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        $display("Test 8: Objects independent");
        if (c2.value == 12) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", c2.value); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
