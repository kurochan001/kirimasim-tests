/*
:name: test_queue_basic
:description: Queue Basic Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_basic.expected
*/
// IEEE 1800-2023 Section 7.10 - Queue Basic Tests
module test_queue_basic;
    int pass_count = 0;
    int fail_count = 0;
    
    int q[$];
    
    initial begin
        $display("=== IEEE 1800-2023 Queue Basic Tests ===");
        
        // Test 1: Push back
        $display("Test 1: Push back");
        q.push_back(10);
        if (q.size() == 1 && q[0] == 10) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end
        
        // Test 2: Multiple push
        $display("Test 2: Multiple push");
        q.push_back(20);
        q.push_back(30);
        if (q.size() == 3) begin $display("Test 2 PASS: size=%0d", q.size()); pass_count++; end
        else begin $display("Test 2 FAIL: size=%0d", q.size()); fail_count++; end
        
        // Test 3: Pop front
        $display("Test 3: Pop front");
        if (q.pop_front() == 10) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end
        
        // Test 4: Size after pop
        $display("Test 4: Size");
        if (q.size() == 2) begin $display("Test 4 PASS: size=%0d", q.size()); pass_count++; end
        else begin $display("Test 4 FAIL: size=%0d", q.size()); fail_count++; end
        
        // Test 5: Push front
        $display("Test 5: Push front");
        q.push_front(5);
        if (q[0] == 5) begin $display("Test 5 PASS: [0]=%0d", q[0]); pass_count++; end
        else begin $display("Test 5 FAIL: [0]=%0d", q[0]); fail_count++; end
        
        // Test 6: Pop back
        $display("Test 6: Pop back");
        if (q.pop_back() == 30) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end
        
        // Test 7: Delete all
        $display("Test 7: Delete");
        q.delete();
        if (q.size() == 0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: size=%0d", q.size()); fail_count++; end
        
        // Test 8: Refill
        $display("Test 8: Refill");
        q.push_back(100);
        q.push_back(200);
        if (q[0] == 100 && q[1] == 200) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
