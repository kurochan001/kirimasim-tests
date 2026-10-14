/*
:name: test_array_slice_edge
:description: Test: Array slicing edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 7.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_slice_edge.expected
*/
// Test: Array slicing edge cases
module test_array_slice_edge;
    int pass_count = 0;
    int test_count = 0;
    
    logic [31:0] word;
    logic [7:0] bytes [0:3];
    logic [63:0] dword;
    
    initial begin
        // Test 1: Full word select
        test_count++;
        word = 32'h12345678;
        if (word[31:0] == 32'h12345678) pass_count++;
        
        // Test 2: Upper half select
        test_count++;
        if (word[31:16] == 16'h1234) pass_count++;
        
        // Test 3: Lower half select
        test_count++;
        if (word[15:0] == 16'h5678) pass_count++;
        
        // Test 4: Single byte select
        test_count++;
        if (word[7:0] == 8'h78) pass_count++;
        
        // Test 5: Single bit select
        test_count++;
        if (word[0] == 1'b0) pass_count++;
        
        // Test 6: Indexed part select +
        test_count++;
        if (word[8+:8] == 8'h56) pass_count++;
        
        // Test 7: Indexed part select -
        test_count++;
        if (word[15-:8] == 8'h56) pass_count++;
        
        // Test 8: Array element access
        test_count++;
        bytes[0] = 8'hAA;
        bytes[1] = 8'hBB;
        bytes[2] = 8'hCC;
        bytes[3] = 8'hDD;
        if (bytes[2] == 8'hCC) pass_count++;
        
        // Test 9: Wide word slice
        test_count++;
        dword = 64'hFEDCBA98_76543210;
        if (dword[31:0] == 32'h76543210) pass_count++;
        
        // Test 10: Non-aligned slice
        test_count++;
        if (word[19:12] == 8'h45) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
