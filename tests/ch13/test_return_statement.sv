/*
:name: test_return_statement
:description: Return Statement Tests
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_return_statement.expected
*/
// IEEE 1800-2023 Section 13.4.1 - Return Statement Tests
module test_return_statement;
    int pass_count = 0;
    int fail_count = 0;

    // Function with early return
    function int find_first_positive(int arr[5]);
        for (int i = 0; i < 5; i++) begin
            if (arr[i] > 0) return arr[i];
        end
        return -1;
    endfunction

    // Function with conditional return
    function int abs_value(int x);
        if (x < 0) return -x;
        return x;
    endfunction

    // Function with multiple paths
    function int sign(int x);
        if (x > 0) return 1;
        else if (x < 0) return -1;
        else return 0;
    endfunction

    // Function computing factorial
    function int factorial(int n);
        static int result = 1;
        for (int i = 2; i <= n; i++) result = result * i;
        return result;
    endfunction

    // Function with return in loop
    function int find_index(int arr[5], int target);
        for (int i = 0; i < 5; i++) begin
            if (arr[i] == target) return i;
        end
        return -1;
    endfunction

    // Function returning boolean-like
    function int is_even(int x);
        return (x % 2 == 0) ? 1 : 0;
    endfunction

    // Function with nested conditions
    function int clamp(int x, int min_val, int max_val);
        if (x < min_val) return min_val;
        if (x > max_val) return max_val;
        return x;
    endfunction

    // Function with expression return
    function int square(int x);
        return x * x;
    endfunction

    initial begin
        static int arr[5] = '{-3, -1, 0, 5, 10};
        static int arr2[5] = '{10, 20, 30, 40, 50};
        int result;

        $display("=== IEEE 1800-2023 Return Statement Tests ===");

        // Test 1: Early return
        $display("Test 1: Early return in loop");
        result = find_first_positive(arr);
        if (result == 5) begin $display("Test 1 PASS: result=%0d", result); pass_count++; end
        else begin $display("Test 1 FAIL: got %0d", result); fail_count++; end

        // Test 2: Conditional return (negative)
        $display("Test 2: Abs value negative");
        result = abs_value(-42);
        if (result == 42) begin $display("Test 2 PASS: result=%0d", result); pass_count++; end
        else begin $display("Test 2 FAIL: got %0d", result); fail_count++; end

        // Test 3: Conditional return (positive)
        $display("Test 3: Abs value positive");
        result = abs_value(17);
        if (result == 17) begin $display("Test 3 PASS: result=%0d", result); pass_count++; end
        else begin $display("Test 3 FAIL: got %0d", result); fail_count++; end

        // Test 4: Multiple return paths
        $display("Test 4: Sign function");
        if (sign(10) == 1 && sign(-5) == -1 && sign(0) == 0) begin
            $display("Test 4 PASS: sign works"); pass_count++;
        end
        else begin $display("Test 4 FAIL"); fail_count++; end

        // Test 5: Factorial computation
        $display("Test 5: Factorial");
        result = factorial(5);
        if (result == 120) begin $display("Test 5 PASS: 5!=%0d", result); pass_count++; end
        else begin $display("Test 5 FAIL: got %0d", result); fail_count++; end

        // Test 6: Find index
        $display("Test 6: Find index");
        result = find_index(arr2, 30);
        if (result == 2) begin $display("Test 6 PASS: index=%0d", result); pass_count++; end
        else begin $display("Test 6 FAIL: got %0d", result); fail_count++; end

        // Test 7: Clamp function
        $display("Test 7: Clamp value");
        if (clamp(5, 0, 10) == 5 && clamp(-5, 0, 10) == 0 && clamp(15, 0, 10) == 10) begin
            $display("Test 7 PASS: clamp works"); pass_count++;
        end
        else begin $display("Test 7 FAIL"); fail_count++; end

        // Test 8: Expression return
        $display("Test 8: Square function");
        result = square(7);
        if (result == 49) begin $display("Test 8 PASS: 7^2=%0d", result); pass_count++; end
        else begin $display("Test 8 FAIL: got %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
