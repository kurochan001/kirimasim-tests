/*
:name: test_task_func
:description: Test for task and function
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 13.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_func.expected
*/
// Test for task and function
// IEEE 1800-2023 §13.3 and §13.4

module test_task_func;
    int result;
    int pass_count = 0;
    int test_count = 0;

    function int add(int a, int b);
        return a + b;
    endfunction

    function int multiply(int a, int b);
        return a * b;
    endfunction

    task compute(input int x, output int y);
        y = x * 2 + 1;
    endtask

    task void_task(int val);
        result = val;
    endtask

    initial begin
        // Test 1: Simple function
        test_count++;
        result = add(3, 4);
        if (result == 7) begin
            $display("Test 1: Simple function PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Function composition
        test_count++;
        result = add(multiply(2, 3), 4);
        if (result == 10) begin
            $display("Test 2: Function composition PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Task with output
        test_count++;
        compute(5, result);
        if (result == 11) begin
            $display("Test 3: Task with output PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Void task
        test_count++;
        void_task(42);
        if (result == 42) begin
            $display("Test 4: Void task PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Nested calls
        test_count++;
        result = multiply(add(1, 2), add(3, 4));
        if (result == 21) begin
            $display("Test 5: Nested calls PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
