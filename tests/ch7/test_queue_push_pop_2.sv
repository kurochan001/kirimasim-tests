/*
:name: test_queue_push_pop_2
:description: Queue push_front, push_back, pop_front and pop_back
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_push_pop_2.expected
*/
// Queue push_front, push_back, pop_front and pop_back
module test_queue_push_pop;
    int q[$];
    int val;
    
    initial begin
        // Push front and back
        q.push_front(1);
        q.push_back(2);
        q.push_front(0);
        
        // Pop front and back
        val = q.pop_front();
        if (val != 0) $display("FAIL: pop_front expected 0, got %0d", val);
        
        val = q.pop_back();
        if (val != 2) $display("FAIL: pop_back expected 2, got %0d", val);
        
        if (q.size() == 1 && q[0] == 1)
            $display("PASS: Queue push/pop operations");
        else
            $display("FAIL: Queue state incorrect");
        $finish;
    end
endmodule
