/*
:name: test_stmt_return
:description: Test for return statement
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1 12.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_return.expected
*/
// Test for return statement
// IEEE 1800-2023 §13.4.1 and §12.8: Return statement
module test_stmt_return;
    function int add(int a, int b);
        return a + b;
    endfunction

    function int early_return(int val);
        if (val < 0) return -1;
        if (val == 0) return 0;
        return val * 2;
    endfunction

    function void no_return();
        int x;
        x = 10;
        return;
    endfunction

    task automatic my_task(output int result);
        result = 42;
        return;
    endtask

    initial begin
        int result;

        // Simple return
        result = add(3, 4);
        if (result != 7) $display("FAIL: Simple return %0d", result);

        // Early return negative
        result = early_return(-5);
        if (result != -1) $display("FAIL: Early return neg %0d", result);

        // Early return zero
        result = early_return(0);
        if (result != 0) $display("FAIL: Early return zero %0d", result);

        // Normal return
        result = early_return(5);
        if (result != 10) $display("FAIL: Normal return %0d", result);

        // Void function return
        no_return();

        // Task return
        my_task(result);
        if (result != 42) $display("FAIL: Task return %0d", result);

        $display("PASS: Return statement");
        $finish;
    end
endmodule
