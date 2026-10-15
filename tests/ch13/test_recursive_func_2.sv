/*
:name: test_recursive_func_2
:description: Recursive automatic functions: factorial, Fibonacci, sum, binary search, power, GCD
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_recursive_func_2.expected
*/
// Recursive automatic functions: factorial, Fibonacci, sum, binary search, power, GCD
module test_recursive_func;
    int pass_count = 0;
    int total_tests = 10;

    // Factorial function
    function automatic int factorial(int n);
        if (n <= 1)
            return 1;
        else
            return n * factorial(n - 1);
    endfunction

    // Fibonacci function
    function automatic int fibonacci(int n);
        if (n <= 0)
            return 0;
        else if (n == 1)
            return 1;
        else
            return fibonacci(n - 1) + fibonacci(n - 2);
    endfunction

    // Sum of array elements recursively
    function automatic int sum_array(int arr[], int idx);
        if (idx >= arr.size())
            return 0;
        else
            return arr[idx] + sum_array(arr, idx + 1);
    endfunction

    // Binary search recursive
    function automatic int binary_search(int arr[], int target, int lo, int hi);
        int mid;
        if (lo > hi)
            return -1;
        mid = (lo + hi) / 2;
        if (arr[mid] == target)
            return mid;
        else if (arr[mid] > target)
            return binary_search(arr, target, lo, mid - 1);
        else
            return binary_search(arr, target, mid + 1, hi);
    endfunction

    // Power function
    function automatic int power(int base, int exp);
        if (exp == 0)
            return 1;
        else if (exp == 1)
            return base;
        else
            return base * power(base, exp - 1);
    endfunction

    // GCD using Euclidean algorithm
    function automatic int gcd(int a, int b);
        if (b == 0)
            return a;
        else
            return gcd(b, a % b);
    endfunction

    // Test variables
    int result;
    int test_arr[];
    int search_arr[];

    initial begin
        // Test 1: Factorial base case
        result = factorial(0);
        if (result == 1) begin
            $display("PASS: factorial(0) = 1");
            pass_count++;
        end else begin
            $display("FAIL: factorial(0): expected 1, got %0d", result);
        end

        // Test 2: Factorial small value
        result = factorial(5);
        if (result == 120) begin
            $display("PASS: factorial(5) = 120");
            pass_count++;
        end else begin
            $display("FAIL: factorial(5): expected 120, got %0d", result);
        end

        // Test 3: Fibonacci base cases
        if (fibonacci(0) == 0 && fibonacci(1) == 1) begin
            $display("PASS: fibonacci base cases");
            pass_count++;
        end else begin
            $display("FAIL: fibonacci base cases failed");
        end

        // Test 4: Fibonacci larger value
        result = fibonacci(10);
        if (result == 55) begin
            $display("PASS: fibonacci(10) = 55");
            pass_count++;
        end else begin
            $display("FAIL: fibonacci(10): expected 55, got %0d", result);
        end

        // Test 5: Recursive array sum
        test_arr = new[5];
        test_arr[0] = 1; test_arr[1] = 2; test_arr[2] = 3;
        test_arr[3] = 4; test_arr[4] = 5;
        result = sum_array(test_arr, 0);
        if (result == 15) begin
            $display("PASS: sum_array = 15");
            pass_count++;
        end else begin
            $display("FAIL: sum_array: expected 15, got %0d", result);
        end

        // Test 6: Binary search found
        search_arr = new[7];
        search_arr[0] = 10; search_arr[1] = 20; search_arr[2] = 30;
        search_arr[3] = 40; search_arr[4] = 50; search_arr[5] = 60;
        search_arr[6] = 70;
        result = binary_search(search_arr, 40, 0, 6);
        if (result == 3) begin
            $display("PASS: binary_search found at index 3");
            pass_count++;
        end else begin
            $display("FAIL: binary_search: expected 3, got %0d", result);
        end

        // Test 7: Binary search not found
        result = binary_search(search_arr, 35, 0, 6);
        if (result == -1) begin
            $display("PASS: binary_search not found returns -1");
            pass_count++;
        end else begin
            $display("FAIL: binary_search not found: expected -1, got %0d", result);
        end

        // Test 8: Power function
        result = power(2, 10);
        if (result == 1024) begin
            $display("PASS: power(2,10) = 1024");
            pass_count++;
        end else begin
            $display("FAIL: power(2,10): expected 1024, got %0d", result);
        end

        // Test 9: GCD
        result = gcd(48, 18);
        if (result == 6) begin
            $display("PASS: gcd(48,18) = 6");
            pass_count++;
        end else begin
            $display("FAIL: gcd(48,18): expected 6, got %0d", result);
        end

        // Test 10: Power base case
        result = power(5, 0);
        if (result == 1) begin
            $display("PASS: power(5,0) = 1");
            pass_count++;
        end else begin
            $display("FAIL: power(5,0): expected 1, got %0d", result);
        end

        $display("PASS: recursive_func (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
