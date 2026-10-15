/*
:name: test_hierarchy_func
:description: Test: Hierarchical function call
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.6 13.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_hierarchy_func.expected
*/
// Test: Hierarchical function call
module math_unit;
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        else return n * factorial(n - 1);
    endfunction

    function automatic int fibonacci(int n);
        if (n <= 1) return n;
        else return fibonacci(n-1) + fibonacci(n-2);
    endfunction

    function int add(int a, int b);
        return a + b;
    endfunction

    function int multiply(int a, int b);
        return a * b;
    endfunction

    function logic [7:0] pack_nibbles(logic [3:0] hi, logic [3:0] lo);
        return {hi, lo};
    endfunction
endmodule

module string_unit;
    function automatic int str_length(string s);
        return s.len();
    endfunction

    function automatic string str_upper(string s);
        string result;
        result = s.toupper();
        return result;
    endfunction
endmodule

module container;
    math_unit u_math();
    string_unit u_str();

    function int get_magic_number();
        return 42;
    endfunction
endmodule

module test_hierarchy_func;
    container u_container();

    int result;
    logic [7:0] packed_val;
    string str_result;

    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Simple hierarchical function call
        result = u_container.u_math.add(15, 27);
        if (result == 42) begin
            $display("PASS: Test 1 - Simple function call (15 + 27 = 42)");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - result = %0d, expected 42", result);
            fail_count++;
        end

        // Test 2: Function with multiple operations
        result = u_container.u_math.multiply(7, 8);
        if (result == 56) begin
            $display("PASS: Test 2 - Multiply function (7 * 8 = 56)");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - result = %0d, expected 56", result);
            fail_count++;
        end

        // Test 3: Recursive function (factorial)
        result = u_container.u_math.factorial(5);
        if (result == 120) begin
            $display("PASS: Test 3 - Recursive factorial (5! = 120)");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - result = %0d, expected 120", result);
            fail_count++;
        end

        // Test 4: Another recursive function (fibonacci)
        result = u_container.u_math.fibonacci(10);
        if (result == 55) begin
            $display("PASS: Test 4 - Recursive fibonacci (fib(10) = 55)");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - result = %0d, expected 55", result);
            fail_count++;
        end

        // Test 5: Function returning packed value
        packed_val = u_container.u_math.pack_nibbles(4'hA, 4'h5);
        if (packed_val == 8'hA5) begin
            $display("PASS: Test 5 - Pack nibbles function");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - packed_val = %h, expected A5", packed_val);
            fail_count++;
        end

        // Test 6: String function - length
        result = u_container.u_str.str_length("Hello");
        if (result == 5) begin
            $display("PASS: Test 6 - String length function");
            pass_count++;
        end else begin
            $display("FAIL: Test 6 - length = %0d, expected 5", result);
            fail_count++;
        end

        // Test 7: Container's own function
        result = u_container.get_magic_number();
        if (result == 42) begin
            $display("PASS: Test 7 - Container function call");
            pass_count++;
        end else begin
            $display("FAIL: Test 7 - result = %0d, expected 42", result);
            fail_count++;
        end

        $display("\n=== Hierarchical Function Call Test Summary ===");
        $display("PASS: %0d, FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
