/*
:name: test_array_assign_edge
:description: Test: Array assignment edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 7.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_assign_edge.expected
*/
// Test: Array assignment edge cases
module test_array_assign_edge;
    int pass_count = 0;
    int test_count = 0;
    
    logic [31:0] word;
    logic [7:0] arr [0:3];
    logic [15:0] arr2d [0:1][0:1];
    
    initial begin
        // Test 1: Part select assignment
        test_count++;
        word = 32'h0;
        word[7:0] = 8'hAB;
        if (word == 32'h000000AB) pass_count++;
        
        // Test 2: Upper part assignment
        test_count++;
        word[31:24] = 8'hCD;
        if (word == 32'hCD0000AB) pass_count++;
        
        // Test 3: Middle part assignment
        test_count++;
        word[23:8] = 16'h1234;
        if (word == 32'hCD1234AB) pass_count++;
        
        // Test 4: Single bit assignment
        test_count++;
        word[0] = 1'b0;
        if (word[0] == 1'b0) pass_count++;
        
        // Test 5: Array element assignment
        test_count++;
        arr[0] = 8'h11;
        arr[1] = 8'h22;
        arr[2] = 8'h33;
        arr[3] = 8'h44;
        if (arr[1] == 8'h22) pass_count++;
        
        // Test 6: 2D array assignment
        test_count++;
        arr2d[0][0] = 16'hAAAA;
        arr2d[0][1] = 16'hBBBB;
        arr2d[1][0] = 16'hCCCC;
        arr2d[1][1] = 16'hDDDD;
        if (arr2d[1][0] == 16'hCCCC) pass_count++;
        
        // Test 7: Indexed part select assign
        test_count++;
        word = 32'h0;
        word[8+:8] = 8'hEF;
        if (word == 32'h0000EF00) pass_count++;
        
        // Test 8: Full array copy
        test_count++;
        arr = '{8'hAA, 8'hBB, 8'hCC, 8'hDD};
        if (arr[0] == 8'hAA && arr[3] == 8'hDD) pass_count++;
        
        // Test 9: Clear via assignment
        test_count++;
        word = 32'hFFFFFFFF;
        word = 32'h0;
        if (word == 0) pass_count++;
        
        // Test 10: Pattern assignment
        test_count++;
        arr = '{default: 8'h55};
        if (arr[0] == 8'h55 && arr[2] == 8'h55) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
