/*
:name: test_function_call_patterns
:description: Test for function call patterns
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.5.3 13.5.4 13.4.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_call_patterns.expected
*/
// Test for function call patterns
// IEEE 1800-2023 §13

module test_function_call_patterns;
    int pass_count = 0;
    int test_count = 0;
    int result;

    // Simple function
    function int add(int a, int b);
        return a + b;
    endfunction

    // Function with default argument
    function int add_default(int a, int b = 10);
        return a + b;
    endfunction

    // Function with output argument
    function void get_values(output int x, output int y);
        x = 100;
        y = 200;
    endfunction

    // Recursive function
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    // Task with ref argument (ref requires automatic)
    task automatic increment(ref int val);
        val++;
    endtask

    // Function returning array
    function int get_array_sum(int arr[3]);
        return arr[0] + arr[1] + arr[2];
    endfunction

    // Nested function call helper
    function int square(int x);
        return x * x;
    endfunction

    function int double_val(int x);
        return x * 2;
    endfunction

    int x, y;
    int arr[3] = '{1, 2, 3};

    initial begin
        // Test 1: Simple function call
        test_count++;
        result = add(5, 3);
        if (result == 8) begin
            $display("Test 1: add(5,3) = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 1: add(5,3) = %0d FAIL", result);
        end

        // Test 2: Function with default argument
        test_count++;
        result = add_default(5);  // b defaults to 10
        if (result == 15) begin
            $display("Test 2: add_default(5) = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 2: add_default(5) = %0d FAIL", result);
        end

        // Test 3: Function with explicit override
        test_count++;
        result = add_default(5, 20);
        if (result == 25) begin
            $display("Test 3: add_default(5,20) = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 3: add_default(5,20) = %0d FAIL", result);
        end

        // Test 4: Output arguments
        test_count++;
        get_values(x, y);
        if (x == 100 && y == 200) begin
            $display("Test 4: output args x=%0d y=%0d PASS", x, y);
            pass_count++;
        end else begin
            $display("Test 4: output args x=%0d y=%0d FAIL", x, y);
        end

        // Test 5: Recursive function
        test_count++;
        result = factorial(5);
        if (result == 120) begin
            $display("Test 5: factorial(5) = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 5: factorial(5) = %0d FAIL", result);
        end

        // Test 6: Ref argument
        test_count++;
        x = 10;
        increment(x);
        if (x == 11) begin
            $display("Test 6: ref increment x=%0d PASS", x);
            pass_count++;
        end else begin
            $display("Test 6: ref increment x=%0d FAIL", x);
        end

        // Test 7: Array argument
        test_count++;
        result = get_array_sum(arr);
        if (result == 6) begin
            $display("Test 7: array sum = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 7: array sum = %0d FAIL", result);
        end

        // Test 8: Nested function calls
        test_count++;
        result = double_val(square(3));  // 3^2=9, 9*2=18
        if (result == 18) begin
            $display("Test 8: nested calls = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 8: nested calls = %0d FAIL", result);
        end

        // Test 9: Named arguments (not all simulators support)
        test_count++;
        result = add(.a(10), .b(20));
        if (result == 30) begin
            $display("Test 9: named args = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 9: named args = %0d FAIL", result);
        end

        // Test 10: Expression as argument
        test_count++;
        result = add(2 + 3, 4 * 5);
        if (result == 25) begin
            $display("Test 10: expr args = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 10: expr args = %0d FAIL", result);
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
