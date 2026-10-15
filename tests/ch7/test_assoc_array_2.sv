/*
:name: test_assoc_array_2
:description: Associative array with string and int keys: lookup, size, exists, delete
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array_2.expected
*/
`timescale 1ns/1ps
module test_assoc_array_2;
    int aa[string];
    int aa_int[int];
    string keys[$];
    
    int fails = 0;

    
    initial begin
        aa["one"] = 1;
        aa["two"] = 2;
        aa["three"] = 3;
        
        if (aa["two"] != 2) begin fails++; $display("FAIL: string key"); end
        if (aa.size() != 3) begin fails++; $display("FAIL: size"); end
        
        if (!aa.exists("one")) begin fails++; $display("FAIL: exists"); end
        aa.delete("one");
        if (aa.exists("one")) begin fails++; $display("FAIL: delete"); end
        
        aa_int[100] = 10;
        aa_int[200] = 20;
        if (aa_int[100] != 10) begin fails++; $display("FAIL: int key"); end
        
        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
