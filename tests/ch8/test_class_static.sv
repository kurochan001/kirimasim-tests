/*
:name: test_class_static
:description: Static class property counting constructed objects, read through a static method
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.9 8.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_static.expected
*/
`timescale 1ns/1ps
class Counter;
    static int count = 0;
    int id;
    
    function new();
        count++;
        id = count;
    endfunction
    
    static function int get_count();
        return count;
    endfunction
endclass

module test_class_static;
    Counter c1, c2, c3;
    
    int fails = 0;

    
    initial begin
        c1 = new();
        c2 = new();
        c3 = new();
        
        if (Counter::get_count() != 3) begin fails++; $display("FAIL: static count"); end
        if (c1.id != 1) begin fails++; $display("FAIL: c1 id"); end
        if (c3.id != 3) begin fails++; $display("FAIL: c3 id"); end
        
        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
