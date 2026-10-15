/*
:name: test_task_automatic_calls
:description: Automatic tasks that update a module variable (IEEE 1800-2023 Section 13.3.1)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 13.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_automatic_calls.expected
*/
// IEEE 1800-2023 Section 13.3.1 - Automatic task calls
module test_task_automatic_calls;
    int pass_count = 0;
    int fail_count = 0;
    int global_val;

    task automatic set_val(int v);
        global_val = v;
    endtask

    task automatic add_val(int v);
        global_val = global_val + v;
    endtask

    task automatic mult_val(int v);
        global_val = global_val * v;
    endtask

    task automatic reset_val();
        global_val = 0;
    endtask

    initial begin
        $display("=== IEEE 1800-2023 Task Return Tests ===");

        // Test 1: Set value
        $display("Test 1: Set");
        set_val(10);
        if (global_val == 10) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", global_val); fail_count++; end

        // Test 2: Add value
        $display("Test 2: Add");
        add_val(5);
        if (global_val == 15) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", global_val); fail_count++; end

        // Test 3: Multiply
        $display("Test 3: Mult");
        mult_val(2);
        if (global_val == 30) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", global_val); fail_count++; end

        // Test 4: Reset
        $display("Test 4: Reset");
        reset_val();
        if (global_val == 0) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", global_val); fail_count++; end

        // Test 5: Set zero
        $display("Test 5: Set zero");
        set_val(0);
        if (global_val == 0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", global_val); fail_count++; end

        // Test 6: Negative
        $display("Test 6: Negative");
        set_val(-10);
        if (global_val == -10) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", global_val); fail_count++; end

        // Test 7: Chain
        $display("Test 7: Chain");
        set_val(5);
        add_val(3);
        mult_val(2);
        if (global_val == 16) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", global_val); fail_count++; end

        // Test 8: Large
        $display("Test 8: Large");
        set_val(1000);
        add_val(234);
        if (global_val == 1234) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", global_val); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
