/*
:name: test_return_stmt_2
:description: return from functions in conditions, loops and case statements
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1 13.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_return_stmt_2.expected
*/
// return from functions in conditions, loops and case statements

module test_return_stmt;
    int pass_count = 0;
    int total_tests = 10;

    // Test functions
    function int simple_return(int x);
        return x * 2;
    endfunction

    function int conditional_return(int x);
        if (x < 0) return -1;
        if (x == 0) return 0;
        return 1;
    endfunction

    function int early_return(int x);
        if (x > 100) return 100;
        if (x < 0) return 0;
        return x;
    endfunction

    function int loop_return(int n);
        int sum;
        sum = 0;
        for (int i = 0; i < n; i++) begin
            sum += i;
            if (sum > 50) return sum;
        end
        return sum;
    endfunction

    function int nested_conditional(int a, int b);
        if (a > 0) begin
            if (b > 0) return 1;
            else return 2;
        end else begin
            if (b > 0) return 3;
            else return 4;
        end
    endfunction

    // A recursive function must be automatic: the calls of a static function
    // share one copy of n (13.4.2).
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    function logic [7:0] pack_nibbles(logic [3:0] hi, logic [3:0] lo);
        return {hi, lo};
    endfunction

    function string return_string(int code);
        case (code)
            0: return "zero";
            1: return "one";
            2: return "two";
            default: return "unknown";
        endcase
    endfunction

    function int void_style();
        int x;
        x = 42;
        return x;
    endfunction

    function int multiple_paths(int a, int b, int c);
        if (a == 0) return 0;
        if (b == 0) return a;
        if (c == 0) return a + b;
        return a + b + c;
    endfunction

    initial begin
        // Test 1: Simple return
        if (simple_return(5) == 10) pass_count++;

        // Test 2: Conditional return - negative
        if (conditional_return(-5) == -1) pass_count++;

        // Test 3: Conditional return - zero and positive
        if (conditional_return(0) == 0 && conditional_return(5) == 1) pass_count++;

        // Test 4: Early return
        if (early_return(150) == 100 && early_return(-5) == 0 && early_return(50) == 50)
            pass_count++;

        // Test 5: Return from loop
        if (loop_return(5) == 10 && loop_return(20) == 55) pass_count++;

        // Test 6: Nested conditional return
        if (nested_conditional(1, 1) == 1 && nested_conditional(1, -1) == 2 &&
            nested_conditional(-1, 1) == 3 && nested_conditional(-1, -1) == 4)
            pass_count++;

        // Test 7: Recursive function with return
        if (factorial(5) == 120) pass_count++;

        // Test 8: Return packed value
        if (pack_nibbles(4'hA, 4'h5) == 8'hA5) pass_count++;

        // Test 9: Return string
        if (return_string(1) == "one" && return_string(99) == "unknown") pass_count++;

        // Test 10: Multiple return paths
        if (multiple_paths(0, 1, 2) == 0 && multiple_paths(1, 0, 2) == 1 &&
            multiple_paths(1, 2, 0) == 3 && multiple_paths(1, 2, 3) == 6)
            pass_count++;

        $display("PASS: return_stmt (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
