/*
:name: test_void_func
:description: Void Function Tests
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_void_func.expected
*/
// IEEE 1800-2023 Section 13.4.1 - Void Function Tests
module test_void_func;
    int pass_count = 0;
    int fail_count = 0;

    int global_val;

    function void set_val(int v);
        global_val = v;
    endfunction

    function void add_to_val(int v);
        global_val = global_val + v;
    endfunction

    function void mult_val(int v);
        global_val = global_val * v;
    endfunction

    function void clear();
        global_val = 0;
    endfunction

    initial begin

        $display("=== IEEE 1800-2023 Void Function Tests ===");

        // Test 1: Set value
        $display("Test 1: Set value");
        set_val(42);
        if (global_val == 42) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", global_val); fail_count++; end

        // Test 2: Add to value
        $display("Test 2: Add to value");
        global_val = 10;
        add_to_val(5);
        if (global_val == 15) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", global_val); fail_count++; end

        // Test 3: Multiple calls
        $display("Test 3: Multiple calls");
        global_val = 0;
        add_to_val(10);
        add_to_val(20);
        add_to_val(30);
        if (global_val == 60) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", global_val); fail_count++; end

        // Test 4: Clear
        $display("Test 4: Clear");
        global_val = 100;
        clear();
        if (global_val == 0) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", global_val); fail_count++; end

        // Test 5: Mult value
        $display("Test 5: Mult value");
        global_val = 5;
        mult_val(4);
        if (global_val == 20) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", global_val); fail_count++; end

        // Test 6: Chain mult
        $display("Test 6: Chain mult");
        global_val = 2;
        mult_val(2);
        mult_val(2);
        mult_val(2);
        if (global_val == 16) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", global_val); fail_count++; end

        // Test 7: Chain operations
        $display("Test 7: Chain ops");
        clear();
        set_val(50);
        add_to_val(25);
        if (global_val == 75) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", global_val); fail_count++; end

        // Test 8: Set zero
        $display("Test 8: Set zero");
        set_val(0);
        if (global_val == 0) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", global_val); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
