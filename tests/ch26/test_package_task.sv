/*
:name: test_package_task
:description: Package tasks test
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 26.3 13.3 13.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_task.expected
*/
// Package tasks test
package task_pkg;
    // Shared variable for task testing
    int shared_counter = 0;
    int shared_data = 0;

    // Simple task
    task increment_counter();
        shared_counter++;
    endtask

    // Task with input argument
    task set_data(input int value);
        shared_data = value;
    endtask

    // Task with output argument
    task get_counter(output int value);
        value = shared_counter;
    endtask

    // Task with inout argument
    task double_value(inout int value);
        value = value * 2;
    endtask

    // Task with multiple arguments
    task compute(input int a, input int b, output int sum, output int diff);
        sum = a + b;
        diff = a - b;
    endtask

    // Task with delay (automatic for timing)
    task automatic delayed_set(input int value, input int delay_ns);
        #delay_ns;
        shared_data = value;
    endtask

    // Task modifying multiple shared variables
    task reset_all();
        shared_counter = 0;
        shared_data = 0;
    endtask
endpackage

module test_package_task;
    import task_pkg::*;

    int pass_count = 0;
    int fail_count = 0;

    int local_val;
    int sum_result, diff_result;

    initial begin
        // Initialize
        reset_all();
        #1;

        // Test 1: Simple task
        increment_counter();
        increment_counter();
        increment_counter();
        if (shared_counter == 3) begin
            $display("PASS: Test 1 - Simple task increment (counter=%0d)", shared_counter);
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Simple task failed (counter=%0d)", shared_counter);
            fail_count++;
        end

        // Test 2: Task with input
        set_data(42);
        if (shared_data == 42) begin
            $display("PASS: Test 2 - Task with input (data=%0d)", shared_data);
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Task with input failed");
            fail_count++;
        end

        // Test 3: Task with output
        get_counter(local_val);
        if (local_val == 3) begin
            $display("PASS: Test 3 - Task with output (got=%0d)", local_val);
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Task with output failed");
            fail_count++;
        end

        // Test 4: Task with inout
        local_val = 10;
        double_value(local_val);
        if (local_val == 20) begin
            $display("PASS: Test 4 - Task with inout (doubled=%0d)", local_val);
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Task with inout failed");
            fail_count++;
        end

        // Test 5: Task with multiple arguments
        compute(100, 30, sum_result, diff_result);
        if (sum_result == 130 && diff_result == 70) begin
            $display("PASS: Test 5 - Multiple arguments (sum=%0d, diff=%0d)",
                     sum_result, diff_result);
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Multiple arguments failed");
            fail_count++;
        end

        $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
