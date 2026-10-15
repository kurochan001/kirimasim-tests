/*
:name: test_dyn_array_edge
:description: Test: Dynamic array edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5 7.5.1 7.5.2 7.5.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dyn_array_edge.expected
*/
// Test: Dynamic array edge cases
module test_dyn_array_edge;
    int pass_count = 0;
    int test_count = 0;
    
    int da[];
    logic [7:0] ba[];
    int da2[][];
    
    initial begin
        // Test 1: Initial size
        test_count++;
        if (da.size() == 0) pass_count++;
        
        // Test 2: New allocation
        test_count++;
        da = new[5];
        if (da.size() == 5) pass_count++;
        
        // Test 3: Initialize values
        test_count++;
        for (int i = 0; i < 5; i++)
            da[i] = i * 10;
        if (da[2] == 20) pass_count++;
        
        // Test 4: Resize larger
        test_count++;
        da = new[10](da);
        if (da.size() == 10 && da[2] == 20) pass_count++;
        
        // Test 5: Resize smaller
        test_count++;
        da = new[3](da);
        if (da.size() == 3) pass_count++;
        
        // Test 6: Delete
        test_count++;
        da.delete();
        if (da.size() == 0) pass_count++;
        
        // Test 7: Byte array
        test_count++;
        ba = new[4];
        ba = '{8'hAA, 8'hBB, 8'hCC, 8'hDD};
        if (ba[1] == 8'hBB) pass_count++;
        
        // Test 8: Copy array
        test_count++;
        begin
            int da_copy[];
            da = new[3];
            da = '{1, 2, 3};
            da_copy = da;
            if (da_copy[1] == 2) pass_count++;
        end
        
        // Test 9: 2D dynamic array
        test_count++;
        da2 = new[2];
        da2[0] = new[3];
        da2[1] = new[3];
        da2[0][0] = 100;
        if (da2[0][0] == 100) pass_count++;
        
        // Test 10: Large allocation
        test_count++;
        da = new[1000];
        da[999] = 12345;
        if (da[999] == 12345) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
