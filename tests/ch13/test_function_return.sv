/*
:name: test_function_return
:description: return in functions, early and at the end
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_return.expected
*/
// return in functions, early and at the end
`timescale 1ns/1ps
module test_function_return;
    function int early_return(int val);
        if (val < 0) return -1;
        if (val == 0) return 0;
        return val * 2;
    endfunction
    
    function logic [15:0] multi_return(logic [7:0] a, logic [7:0] b);
        return {a, b};
    endfunction
    
    int r;
    logic [15:0] lr;
    
    initial begin
        r = early_return(-5);
        if (r != -1) $display("FAIL: negative");
        
        r = early_return(0);
        if (r != 0) $display("FAIL: zero");
        
        r = early_return(10);
        if (r != 20) $display("FAIL: positive");
        
        lr = multi_return(8'hAB, 8'hCD);
        if (lr != 16'hABCD) $display("FAIL: multi return");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
