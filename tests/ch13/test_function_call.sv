/*
:name: test_function_call
:description: Functions
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.4.2 13.5.2 13.5.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_call.expected
*/
// IEEE 1800-2023 Section 13.4: Functions
module test_function_call;
    int result;

    function int add(int a, int b);
        return a + b;
    endfunction

    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    function int with_default(int a, int b = 10);
        return a + b;
    endfunction

    function automatic void by_ref(ref int x);
        x = x * 2;
    endfunction

    int fails = 0;


    initial begin
        // Basic function call
        result = add(3, 4);
        if (result == 7)
            $display("PASS: add(3, 4) = 7");
        else
            begin fails++; $display("FAIL: add = %0d", result); end

        // Recursive function
        result = factorial(5);
        if (result == 120)
            $display("PASS: factorial(5) = 120");
        else
            begin fails++; $display("FAIL: factorial = %0d", result); end

        // Default argument
        result = with_default(5);
        if (result == 15)
            $display("PASS: with_default(5) = 15");
        else
            begin fails++; $display("FAIL: with_default = %0d", result); end

        result = with_default(5, 20);
        if (result == 25)
            $display("PASS: with_default(5, 20) = 25");
        else
            begin fails++; $display("FAIL: with_default = %0d", result); end

        // Pass by reference
        result = 10;
        by_ref(result);
        if (result == 20)
            $display("PASS: by_ref doubled value");
        else
            begin fails++; $display("FAIL: by_ref = %0d", result); end

        if (fails == 0) $display("TEST PASSED: function call tests completed");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
