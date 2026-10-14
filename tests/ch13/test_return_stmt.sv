/*
:name: test_return_stmt
:description: Return statements
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.4 12.8 13.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_return_stmt.expected
*/
// IEEE 1800-2023 Section 13.4: Return statements
module test_return_stmt;
    int result;

    function int early_return(int n);
        if (n < 0) return -1;
        if (n == 0) return 0;
        return n * 2;
    endfunction

    function int conditional_return(int a, int b);
        if (a > b)
            return a;
        else
            return b;
    endfunction

    function int loop_return(int limit);
        for (int i = 0; i < 100; i++) begin
            if (i >= limit)
                return i;
        end
        return -1;
    endfunction

    task void_return(int n);
        if (n < 0) return;
        result = n;
    endtask

    initial begin
        // Early return negative
        result = early_return(-5);
        if (result == -1)
            $display("PASS: early return neg");
        else
            $display("FAIL: neg = %0d", result);

        // Early return zero
        result = early_return(0);
        if (result == 0)
            $display("PASS: early return zero");
        else
            $display("FAIL: zero = %0d", result);

        // Normal return
        result = early_return(10);
        if (result == 20)
            $display("PASS: normal return");
        else
            $display("FAIL: normal = %0d", result);

        // Conditional return
        result = conditional_return(5, 3);
        if (result == 5)
            $display("PASS: conditional return");
        else
            $display("FAIL: cond = %0d", result);

        // Loop return
        result = loop_return(7);
        if (result == 7)
            $display("PASS: loop return");
        else
            $display("FAIL: loop = %0d", result);

        // Void return
        result = 100;
        void_return(-1);
        if (result == 100)
            $display("PASS: void return skip");
        else
            $display("FAIL: void = %0d", result);

        void_return(50);
        if (result == 50)
            $display("PASS: void return exec");
        else
            $display("FAIL: exec = %0d", result);

        $display("TEST PASSED: return statement tests completed");
        $finish;
    end
endmodule
