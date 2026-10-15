/*
:name: test_function_call_2
:description: Recursive automatic functions, ref arguments, default arguments and array arguments
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.4.2 13.5.2 13.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_call_2.expected
*/
`timescale 1ns/1ps

module test_function_call_2;
    // Various function types
    function automatic int add(int a, int b);
        return a + b;
    endfunction

    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    function automatic void side_effect(ref int x);
        x = x * 2;
    endfunction

    function automatic int default_args(int a, int b = 10, int c = 20);
        return a + b + c;
    endfunction

    function automatic int arr_sum(int arr[], int size);
        int sum = 0;
        for (int i = 0; i < size; i++) sum += arr[i];
        return sum;
    endfunction

    int fails = 0;


    initial begin
        int result;
        static int arr[5] = '{1, 2, 3, 4, 5};
        int x;

        // Simple call
        result = add(3, 4);
        if (result != 7) begin fails++; $display("FAIL: add"); end

        // Recursive call
        result = factorial(5);
        if (result != 120) begin fails++; $display("FAIL: factorial"); end

        // Ref argument
        x = 10;
        side_effect(x);
        if (x != 20) begin fails++; $display("FAIL: side_effect"); end

        // Default arguments
        result = default_args(5);
        if (result != 35) begin fails++; $display("FAIL: default_args"); end

        result = default_args(5, 15);
        if (result != 40) begin fails++; $display("FAIL: default_args partial"); end

        // Array argument
        result = arr_sum(arr, 5);
        if (result != 15) begin fails++; $display("FAIL: arr_sum"); end

        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
