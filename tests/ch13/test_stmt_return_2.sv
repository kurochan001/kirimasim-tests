/*
:name: test_stmt_return_2
:description: Return statement test
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1 12.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_return_2.expected
*/
// Return statement test
module test_stmt_return_2;
    int pass_count = 0;

    // Function with simple return
    function int add(int a, int b);
        return a + b;
    endfunction

    // Function with conditional return
    function int abs_val(int x);
        if (x < 0) return -x;
        return x;
    endfunction

    // Function with early return
    function int find_first_even(int arr[5]);
        for (int i = 0; i < 5; i++) begin
            if (arr[i] % 2 == 0) return arr[i];
        end
        return -1;
    endfunction

    // Function with multiple return paths
    function int classify(int x);
        if (x < 0) return -1;
        if (x == 0) return 0;
        if (x > 0) return 1;
        return 99;  // Never reached
    endfunction

    // Void function with return
    function void process(int x, output int result);
        if (x < 0) begin
            result = 0;
            return;
        end
        result = x * 2;
    endfunction

    initial begin
        int result;
        static int arr[5] = '{1, 3, 4, 5, 7};

        // Scenario 1: Simple return
        result = add(10, 20);
        if (result == 30) pass_count++;
        else $display("FAIL: Simple return result=%0d", result);

        // Scenario 2: Conditional return
        result = abs_val(-15);
        if (result == 15) pass_count++;
        else $display("FAIL: Conditional return result=%0d", result);

        result = abs_val(25);
        if (result == 25) pass_count++;
        else $display("FAIL: Conditional return positive result=%0d", result);

        // Scenario 3: Early return in loop
        result = find_first_even(arr);
        if (result == 4) pass_count++;
        else $display("FAIL: Early return in loop result=%0d", result);

        // Scenario 4: Multiple return paths
        if (classify(-5) == -1 && classify(0) == 0 && classify(5) == 1) pass_count++;
        else $display("FAIL: Multiple return paths");

        // Scenario 5: Void function with return
        process(-10, result);
        if (result == 0) pass_count++;
        else $display("FAIL: Void function early return result=%0d", result);

        process(10, result);
        if (result == 20) pass_count++;
        else $display("FAIL: Void function normal return result=%0d", result);

        if (pass_count == 7) $display("PASS");
        else $display("FAIL: pass_count=%0d", pass_count);
        $finish;
    end
endmodule
