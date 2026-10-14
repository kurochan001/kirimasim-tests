/*
:name: test_queue_edge
:description: Test: Queue operation edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_edge.expected
*/
// Test: Queue operation edge cases
module test_queue_edge;
    int pass_count = 0;
    int test_count = 0;
    
    int q[$];
    int bounded_q[$:10];
    string sq[$];
    
    initial begin
        // Test 1: Empty queue size
        test_count++;
        if (q.size() == 0) pass_count++;
        
        // Test 2: Push back
        test_count++;
        q.push_back(10);
        q.push_back(20);
        q.push_back(30);
        if (q.size() == 3) pass_count++;
        
        // Test 3: Push front
        test_count++;
        q.push_front(5);
        if (q[0] == 5) pass_count++;
        
        // Test 4: Pop back
        test_count++;
        if (q.pop_back() == 30) pass_count++;
        
        // Test 5: Pop front
        test_count++;
        if (q.pop_front() == 5) pass_count++;
        
        // Test 6: Insert
        test_count++;
        q.insert(1, 15);
        if (q[1] == 15) pass_count++;
        
        // Test 7: Delete
        test_count++;
        q.delete(1);
        if (q.size() == 2) pass_count++;
        
        // Test 8: String queue
        test_count++;
        sq.push_back("hello");
        sq.push_back("world");
        if (sq[0] == "hello") pass_count++;
        
        // Test 9: Queue clear
        test_count++;
        q.delete();
        if (q.size() == 0) pass_count++;
        
        // Test 10: Bounded queue
        test_count++;
        for (int i = 0; i < 5; i++)
            bounded_q.push_back(i);
        if (bounded_q.size() == 5) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
