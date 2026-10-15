/*
:name: test_queue_ops_2
:description: Queue push, pop, insert and delete after assignment from a list
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2 10.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_ops_2.expected
*/
// Queue push, pop, insert and delete after assignment from a list
`timescale 1ns/1ps
module test_queue_ops;
    int q[$];
    int val;
    
    initial begin
        q = {1, 2, 3, 4, 5};
        if (q.size() != 5) $display("FAIL: init size");
        
        q.push_back(6);
        if (q.size() != 6) $display("FAIL: push_back");
        
        q.push_front(0);
        if (q[0] != 0) $display("FAIL: push_front");
        
        val = q.pop_front();
        if (val != 0) $display("FAIL: pop_front");
        
        val = q.pop_back();
        if (val != 6) $display("FAIL: pop_back");
        
        q.insert(2, 100);
        if (q[2] != 100) $display("FAIL: insert");
        
        q.delete(2);
        if (q[2] == 100) $display("FAIL: delete");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
