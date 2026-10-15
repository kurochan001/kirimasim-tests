/*
:name: test_mailbox_6
:description: Mailbox put, get and num
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_6.expected
*/
// Mailbox put, get and num (15.4)
`timescale 1ns/1ps
module test_mailbox_6;
    mailbox #(int) mb;
    int val;
    
    int fails = 0;

    
    initial begin
        mb = new();
        
        mb.put(10);
        mb.put(20);
        mb.put(30);
        
        if (mb.num() != 3) begin fails++; $display("FAIL: num"); end
        
        mb.get(val);
        if (val != 10) begin fails++; $display("FAIL: get 1"); end
        
        mb.get(val);
        if (val != 20) begin fails++; $display("FAIL: get 2"); end
        
        if (mb.num() != 1) begin fails++; $display("FAIL: num after get"); end
        
        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
