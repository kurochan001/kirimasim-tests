/*
:name: test_task_basic
:description: Task Basic Tests
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_basic.expected
*/
// IEEE 1800-2023 Section 13.3 - Task Basic Tests
module test_task_basic;
    int pass_count = 0;
    int fail_count = 0;
    int global_val;

    task set_value(int v);
        global_val = v;
    endtask

    task add_value(int v);
        global_val = global_val + v;
    endtask

    task reset_value();
        global_val = 0;
    endtask

    task mult_value(int v);
        global_val = global_val * v;
    endtask

    initial begin
        $display("=== IEEE 1800-2023 Task Basic Tests ===");

        // Test 1: Set value
        $display("Test 1: Set");
        set_value(10);
        if (global_val == 10) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", global_val); fail_count++; end

        // Test 2: Add value
        $display("Test 2: Add");
        add_value(5);
        if (global_val == 15) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", global_val); fail_count++; end

        // Test 3: Reset
        $display("Test 3: Reset");
        reset_value();
        if (global_val == 0) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", global_val); fail_count++; end

        // Test 4: Mult
        $display("Test 4: Mult");
        set_value(7);
        mult_value(3);
        if (global_val == 21) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", global_val); fail_count++; end

        // Test 5: Sequence
        $display("Test 5: Sequence");
        reset_value();
        add_value(10);
        add_value(20);
        if (global_val == 30) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", global_val); fail_count++; end

        // Test 6: Zero
        $display("Test 6: Zero");
        set_value(0);
        if (global_val == 0) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", global_val); fail_count++; end

        // Test 7: Negative
        $display("Test 7: Negative");
        set_value(-100);
        if (global_val == -100) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", global_val); fail_count++; end

        // Test 8: Complex
        $display("Test 8: Complex");
        set_value(5);
        mult_value(4);
        add_value(3);
        if (global_val == 23) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", global_val); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
