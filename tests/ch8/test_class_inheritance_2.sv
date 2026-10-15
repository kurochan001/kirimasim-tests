/*
:name: test_class_inheritance_2
:description: Virtual method override seen through a base-class handle
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.13 8.20
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_inheritance_2.expected
*/
`timescale 1ns/1ps
class Base;
    int x;
    function new(int v); x = v; endfunction
    virtual function int compute(); return x; endfunction
endclass

class Derived extends Base;
    int y;
    function new(int v1, int v2); super.new(v1); y = v2; endfunction
    function int compute(); return x + y; endfunction
endclass

module test_class_inheritance_2;
    Base b;
    Derived d;
    
    int fails = 0;

    
    initial begin
        b = new(10);
        if (b.compute() != 10) begin fails++; $display("FAIL: base"); end
        
        d = new(10, 20);
        if (d.compute() != 30) begin fails++; $display("FAIL: derived"); end
        
        b = d;
        if (b.compute() != 30) begin fails++; $display("FAIL: polymorphism"); end
        
        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
