/*
:name: test_recursive_func
:description: Recursive automatic functions
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_recursive_func.expected
*/
// Recursive automatic functions
`timescale 1ns/1ps
module test_recursive_func;
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction
    
    function automatic int fibonacci(int n);
        if (n <= 1) return n;
        return fibonacci(n - 1) + fibonacci(n - 2);
    endfunction
    
    initial begin
        if (factorial(5) != 120) $display("FAIL: factorial 5");
        if (factorial(0) != 1) $display("FAIL: factorial 0");
        
        if (fibonacci(10) != 55) $display("FAIL: fibonacci 10");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
