/*
:name: test_task_call
:description: Simple task call
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3.1 13.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_call.expected
*/
// IEEE 1800-2023 Section 13.3: Tasks
module test_task_call;
    int result;
    int count;

    task simple_task;
        result = 42;
    endtask

    task task_with_args(int a, int b);
        result = a + b;
    endtask

    task automatic recursive_count(int n);
        if (n > 0) begin
            count = count + 1;
            recursive_count(n - 1);
        end
    endtask

    task task_with_output(input int a, output int b);
        b = a * 2;
    endtask

    initial begin
        // Simple task call
        result = 0;
        simple_task();
        if (result == 42)
            $display("PASS: simple task");
        else
            $display("FAIL: simple = %0d", result);

        // Task with arguments
        task_with_args(10, 20);
        if (result == 30)
            $display("PASS: task with args");
        else
            $display("FAIL: args = %0d", result);

        // Recursive task
        count = 0;
        recursive_count(5);
        if (count == 5)
            $display("PASS: recursive task");
        else
            $display("FAIL: recursive = %0d", count);

        // Task with output
        task_with_output(25, result);
        if (result == 50)
            $display("PASS: task output");
        else
            $display("FAIL: output = %0d", result);

        $display("TEST PASSED: task call tests completed");
        $finish;
    end
endmodule
