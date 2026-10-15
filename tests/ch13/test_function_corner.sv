/*
:name: test_function_corner
:description: Tests function declarations, arguments, return values
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.4.2 13.5.3 13.5.4 6.21
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_corner.expected
*/
// Tests function declarations, arguments, return values
`timescale 1ns/1ps

module test_function_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Basic function
    function int add(int a, int b);
        return a + b;
    endfunction

    // Function with default arguments
    function int multiply(int a, int b = 2);
        return a * b;
    endfunction

    // Function with reference arguments (IEEE 1800-2023: ref requires automatic)
    function automatic void increment(ref int val);
        val++;
    endfunction

    // Function with output arguments
    function int divide(int a, int b, output int remainder);
        remainder = a % b;
        return a / b;
    endfunction

    // Void function
    function void print_val(int v);
        $display("  Value: %0d", v);
    endfunction

    // Recursive function
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    // Function returning array (IEEE 1800-2023 requires typedef for unpacked array return)
    typedef int int_array4[4];

    function int_array4 get_array();
        int_array4 arr;
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;
        arr[3] = 40;
        return arr;
    endfunction

    // Static function
    function static int get_static_counter();
        static int counter = 0;
        counter++;
        return counter;
    endfunction

    // Automatic function
    function automatic int auto_factorial(int n);
        if (n <= 1) return 1;
        return n * auto_factorial(n - 1);
    endfunction

    // Test 1: Basic function call
    task test_basic_function();
        static int result;
        // Assigned here: the standard specifies no order for static initializers
        result = add(3, 5);

        if (result == 8) begin
            $display("PASS: Basic function call works");
            pass_count++;
        end else begin
            $display("FAIL: Basic function failed (result=%0d)", result);
            fail_count++;
        end
    endtask

    // Test 2: Default argument
    task test_default_argument();
        static int result1;
        static int result2;
        // Assigned here: the standard specifies no order for static initializers
        result1 = multiply(5);     // Uses default b=2
        result2 = multiply(5, 3);  // Overrides default

        if (result1 == 10 && result2 == 15) begin
            $display("PASS: Default argument works");
            pass_count++;
        end else begin
            $display("FAIL: Default argument failed");
            fail_count++;
        end
    endtask

    // Test 3: Reference argument
    task test_ref_argument();
        static int val = 10;
        increment(val);

        if (val == 11) begin
            $display("PASS: Reference argument works");
            pass_count++;
        end else begin
            $display("FAIL: Reference argument failed (val=%0d)", val);
            fail_count++;
        end
    endtask

    // Test 4: Output argument
    task test_output_argument();
        int quotient, remainder;

        quotient = divide(17, 5, remainder);

        if (quotient == 3 && remainder == 2) begin
            $display("PASS: Output argument works");
            pass_count++;
        end else begin
            $display("FAIL: Output argument failed");
            fail_count++;
        end
    endtask

    // Test 5: Void function
    task test_void_function();
        print_val(42);
        $display("PASS: Void function works");
        pass_count++;
    endtask

    // Test 6: Recursive function
    task test_recursive_function();
        static int result;
        // Assigned here: the standard specifies no order for static initializers
        result = factorial(5);

        if (result == 120) begin  // 5! = 120
            $display("PASS: Recursive function works");
            pass_count++;
        end else begin
            $display("FAIL: Recursive function failed (result=%0d)", result);
            fail_count++;
        end
    endtask

    // Test 7: Function returning array
    task test_array_return();
        static int_array4 arr = get_array();

        if (arr[0] == 10 && arr[3] == 40) begin
            $display("PASS: Function returning array works");
            pass_count++;
        end else begin
            $display("FAIL: Array return failed");
            fail_count++;
        end
    endtask

    // Test 8: Static function
    task test_static_function();
        static int val1;
        static int val2;
        static int val3;
        // Assigned here: the standard specifies no order for static initializers
        val1 = get_static_counter();
        val2 = get_static_counter();
        val3 = get_static_counter();

        if (val1 == 1 && val2 == 2 && val3 == 3) begin
            $display("PASS: Static function preserves state");
            pass_count++;
        end else begin
            $display("FAIL: Static counter (val3=%0d)", val3);
            fail_count++;
        end
    endtask

    // Test 9: Automatic function
    task test_automatic_function();
        static int result;
        // Assigned here: the standard specifies no order for static initializers
        result = auto_factorial(6);

        if (result == 720) begin  // 6! = 720
            $display("PASS: Automatic recursive function works");
            pass_count++;
        end else begin
            $display("FAIL: Automatic function failed (result=%0d)", result);
            fail_count++;
        end
    endtask

    // Test 10: Function in expression
    task test_function_in_expr();
        static int result;
        // Assigned here: the standard specifies no order for static initializers
        result = add(multiply(2, 3), 4);  // (2*3) + 4 = 10

        if (result == 10) begin
            $display("PASS: Function in expression works");
            pass_count++;
        end else begin
            $display("FAIL: Function in expression failed");
            fail_count++;
        end
    endtask

    // Test 11: Named argument passing
    task test_named_arguments();
        int rem;
        static int result;
        // Assigned here so the result does not depend on the order of static initializers.
        result = divide(.b(3), .a(10), .remainder(rem));
        // 10 / 3 = 3

        if (result == 3) begin
            $display("PASS: Named argument passing works");
            pass_count++;
        end else begin
            $display("FAIL: Named arguments (result=%0d)", result);
            fail_count++;
        end
    endtask

    // Test 12: Function with local variables
    function int compute_sum(int n);
        static int sum = 0;
        for (int i = 1; i <= n; i++) begin
            sum += i;
        end
        return sum;
    endfunction

    task test_local_variables();
        static int result;
        // Assigned here: the standard specifies no order for static initializers
        result = compute_sum(10);

        if (result == 55) begin  // 1+2+...+10 = 55
            $display("PASS: Function with local variables works");
            pass_count++;
        end else begin
            $display("FAIL: Local variables failed (result=%0d)", result);
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Function Corner Cases Test ===");

        test_basic_function();
        test_default_argument();
        test_ref_argument();
        test_output_argument();
        test_void_function();
        test_recursive_function();
        test_array_return();
        test_static_function();
        test_automatic_function();
        test_function_in_expr();
        test_named_arguments();
        test_local_variables();

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
