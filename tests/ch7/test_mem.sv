/*
:name: test_mem
:description: Various array types
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4 7.5 7.8 7.10
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mem.expected
*/
module test_mem;
    int pass_count = 0;
    int test_count = 0;
    
    // Various array types
    logic [7:0] mem[0:255];
    int dyn_arr[];
    int queue[$];
    int assoc[string];
    logic [31:0] packed_arr[4];
    
    initial begin
        // Test 1: Memory write/read
        test_count++;
        mem[100] = 8'hAB;
        if (mem[100] == 8'hAB) pass_count++;
        
        // Test 2: Memory initialization
        test_count++;
        for (int j = 0; j < 10; j++) mem[j] = j;
        if (mem[5] == 5) pass_count++;
        
        // Test 3: Dynamic array
        test_count++;
        dyn_arr = new[5];
        dyn_arr = '{1, 2, 3, 4, 5};
        if (dyn_arr[2] == 3) pass_count++;
        
        // Test 4: Queue push
        test_count++;
        queue.push_back(10);
        queue.push_back(20);
        queue.push_back(30);
        if (queue.size() == 3) pass_count++;
        
        // Test 5: Queue pop
        test_count++;
        if (queue.pop_front() == 10) pass_count++;
        
        // Test 6: Associative array
        test_count++;
        assoc["one"] = 1;
        assoc["two"] = 2;
        if (assoc["two"] == 2) pass_count++;
        
        // Test 7: Packed array
        test_count++;
        packed_arr = '{32'hAAAA, 32'hBBBB, 32'hCCCC, 32'hDDDD};
        if (packed_arr[1] == 32'hBBBB) pass_count++;
        
        // Test 8: Array slice
        test_count++;
        begin
            logic [31:0] slice;
            slice = {mem[3], mem[2], mem[1], mem[0]};
            if (slice == 32'h03020100) pass_count++;
        end
        
        // Test 9: Dynamic resize
        test_count++;
        dyn_arr = new[10](dyn_arr);
        if (dyn_arr.size() == 10 && dyn_arr[2] == 3) pass_count++;
        
        // Test 10: Array methods
        test_count++;
        begin
            static int sum = 0;
            foreach (packed_arr[j]) sum += packed_arr[j];
            if (sum != 0) pass_count++;
        end
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
