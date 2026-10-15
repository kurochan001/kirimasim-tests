/*
:name: test_function_call_recursion
:description: A function call and a recursive automatic function
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_call_recursion.expected
*/
`timescale 1ns/1ps
module test_function_call_recursion;
    function int add(int a, int b);
        return a + b;
    endfunction
    
    // A recursive function must be automatic: the calls of a static function
    // share one copy of n (13.4.2).
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction
    
    initial begin
        if (add(3, 4) != 7) $display("FAIL: add");
        if (factorial(5) != 120) $display("FAIL: factorial");
        $display("TEST PASSED");
        $finish;
    end
endmodule
