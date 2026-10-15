/*
:name: test_class_copy_3
:description: A user-written copy method that copies a value and a fixed-size array member
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.12 8.7
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_copy_3.expected
*/
`timescale 1ns/1ps
class Data;
    int value;
    int arr[3];
    
    function new(int v = 0);
        value = v;
        foreach (arr[i]) arr[i] = i;
    endfunction
    
    function Data copy();
        Data d = new();
        d.value = this.value;
        foreach (arr[i]) d.arr[i] = this.arr[i];
        return d;
    endfunction
endclass

module test_class_copy_3;
    Data d1, d2;
    
    int fails = 0;

    
    initial begin
        d1 = new(100);
        d1.arr[1] = 50;
        
        d2 = d1.copy();
        if (d2.value != 100) begin fails++; $display("FAIL: copy value"); end
        if (d2.arr[1] != 50) begin fails++; $display("FAIL: copy arr"); end
        
        d2.value = 200;
        if (d1.value != 100) begin fails++; $display("FAIL: independence"); end
        
        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
