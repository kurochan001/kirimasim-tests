/*
:name: test_array_methods
:description: Array ordering, locator and reduction methods on a fixed-size array
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1 7.12.2 7.12.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_methods.expected
*/
// Array ordering, locator and reduction methods (7.12)
`timescale 1ns/1ps
module test_array_methods;
    int arr[5] = '{5, 3, 1, 4, 2};
    int result[$];
    int sum_val;
    
    int fails = 0;

    
    initial begin
        arr.sort();
        if (arr[0] != 1) begin fails++; $display("FAIL: sort"); end
        if (arr[4] != 5) begin fails++; $display("FAIL: sort 2"); end
        
        arr.reverse();
        if (arr[0] != 5) begin fails++; $display("FAIL: reverse"); end
        
        result = arr.find with (item > 3);
        if (result.size() != 2) begin fails++; $display("FAIL: find"); end
        
        sum_val = arr.sum();
        if (sum_val != 15) begin fails++; $display("FAIL: sum"); end
        
        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
