/*
:name: test_func_edge_cases
:description: Function edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_edge_cases.expected
*/
// IEEE 1800-2023 §13.4: Function edge cases
// Tests for function declarations and calls

module test_func_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    function automatic int add_func(int a, int b);
        return a + b;
    endfunction

    function automatic int multiply(int x, int y);
        return x * y;
    endfunction

    function automatic logic [7:0] byte_reverse(logic [7:0] data);
        logic [7:0] result;
        for (int i = 0; i < 8; i++) begin
            result[7-i] = data[i];
        end
        return result;
    endfunction

    function automatic int factorial(int n);
        if (n <= 1) return 1;
        else return n * factorial(n - 1);
    endfunction

    function automatic int max_of_three(int a, int b, int c);
        if (a >= b && a >= c) return a;
        else if (b >= c) return b;
        else return c;
    endfunction

    initial begin
        // Test 1: Basic function
        test_count++;
        begin
            static int result = add_func(10, 20);
            if (result == 30) begin
                pass_count++;
                $display("Test 1 PASS: add_func = %0d", result);
            end else begin
                $display("Test 1 FAIL: Func unexpected = %0d", result);
            end
        end

        // Test 2: Multiply function
        test_count++;
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = multiply(7, 8);
            if (result == 56) begin
                pass_count++;
                $display("Test 2 PASS: multiply = %0d", result);
            end else begin
                $display("Test 2 FAIL: Mult unexpected = %0d", result);
            end
        end

        // Test 3: Byte reverse
        test_count++;
        begin
            static logic [7:0] result = byte_reverse(8'b10101010);
            if (result == 8'b01010101) begin
                pass_count++;
                $display("Test 3 PASS: reverse = %b", result);
            end else begin
                $display("Test 3 FAIL: Reverse unexpected = %b", result);
            end
        end

        // Test 4: Recursive factorial
        test_count++;
        begin
            static int result = factorial(5);
            if (result == 120) begin
                pass_count++;
                $display("Test 4 PASS: factorial(5) = %0d", result);
            end else begin
                $display("Test 4 FAIL: Factorial unexpected = %0d", result);
            end
        end

        // Test 5: Max of three
        test_count++;
        begin
            static int result = max_of_three(10, 30, 20);
            if (result == 30) begin
                pass_count++;
                $display("Test 5 PASS: max = %0d", result);
            end else begin
                $display("Test 5 FAIL: Max unexpected = %0d", result);
            end
        end

        // Test 6: Function in expression
        test_count++;
        begin
            static int result = add_func(5, 5) * 2;
            if (result == 20) begin
                pass_count++;
                $display("Test 6 PASS: Expr = %0d", result);
            end else begin
                $display("Test 6 FAIL: Expr unexpected = %0d", result);
            end
        end

        // Test 7: Nested function calls
        test_count++;
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = add_func(multiply(2, 3), multiply(4, 5));
            if (result == 26) begin
                pass_count++;
                $display("Test 7 PASS: Nested = %0d", result);
            end else begin
                $display("Test 7 FAIL: Nested unexpected = %0d", result);
            end
        end

        // Test 8: Zero arguments
        test_count++;
        begin
            static int result = add_func(0, 0);
            if (result == 0) begin
                pass_count++;
                $display("Test 8 PASS: Zero = %0d", result);
            end else begin
                $display("Test 8 FAIL: Zero unexpected = %0d", result);
            end
        end

        // Test 9: Negative result
        test_count++;
        begin
            static int result = add_func(-100, 50);
            if (result == -50) begin
                pass_count++;
                $display("Test 9 PASS: Negative = %0d", result);
            end else begin
                $display("Test 9 FAIL: Neg unexpected = %0d", result);
            end
        end

        // Test 10: Function in loop
        test_count++;
        begin
            static int sum = 0;
            for (int i = 1; i <= 5; i++) begin
                sum += factorial(i);
            end
            if (sum == 153) begin  // 1+2+6+24+120
                pass_count++;
                $display("Test 10 PASS: Loop sum = %0d", sum);
            end else begin
                $display("Test 10 FAIL: Loop unexpected = %0d", sum);
            end
        end

        // Test 11: Factorial edge
        test_count++;
        begin
            static int result = factorial(0);
            if (result == 1) begin
                pass_count++;
                $display("Test 11 PASS: factorial(0) = %0d", result);
            end else begin
                $display("Test 11 FAIL: Fact0 unexpected = %0d", result);
            end
        end

        // Test 12: Reverse zeros
        test_count++;
        begin
            static logic [7:0] result = byte_reverse(8'h00);
            if (result == 8'h00) begin
                pass_count++;
                $display("Test 12 PASS: Reverse zero = %h", result);
            end else begin
                $display("Test 12 FAIL: RevZ unexpected = %h", result);
            end
        end

        $display("=== Function Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
