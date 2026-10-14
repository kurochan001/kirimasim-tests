/*
:name: test_func_void
:description: Void Function Tests
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_void.expected
*/
// IEEE 1800-2023 Section 13.4.1 - Void Function Tests
module test_func_void;
    int pass_count = 0;
    int fail_count = 0;

    int global_val = 0;

    function void set_val(int v);
        global_val = v;
    endfunction

    function void add_val(int v);
        global_val = global_val + v;
    endfunction

    function void double_val();
        global_val = global_val * 2;
    endfunction

    function void reset();
        global_val = 0;
    endfunction

    initial begin
        $display("=== IEEE 1800-2023 Void Function Tests ===");

        $display("Test 1: Initial val");
        if (global_val == 0) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", global_val); fail_count++; end

        $display("Test 2: Set val");
        set_val(10);
        if (global_val == 10) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", global_val); fail_count++; end

        $display("Test 3: Add val");
        add_val(5);
        if (global_val == 15) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", global_val); fail_count++; end

        $display("Test 4: Double val");
        double_val();
        if (global_val == 30) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", global_val); fail_count++; end

        $display("Test 5: Reset");
        reset();
        if (global_val == 0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", global_val); fail_count++; end

        $display("Test 6: Sequence calls");
        set_val(5);
        add_val(3);
        double_val();
        if (global_val == 16) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", global_val); fail_count++; end

        $display("Test 7: Chain reset");
        reset();
        set_val(100);
        if (global_val == 100) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", global_val); fail_count++; end

        $display("Test 8: Multiple adds");
        reset();
        add_val(1);
        add_val(2);
        add_val(3);
        if (global_val == 6) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", global_val); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
