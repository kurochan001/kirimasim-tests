/*
:name: test_replication_edge
:description: Test: Replication operation edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_replication_edge.expected
*/
// Test: Replication operation edge cases
module test_replication_edge;
    int pass_count = 0;
    int test_count = 0;
    
    logic [31:0] result;
    logic [7:0] byte_val;
    logic [3:0] nibble;
    logic bit_val;
    
    initial begin
        // Test 1: Replicate single bit
        test_count++;
        bit_val = 1'b1;
        result = {32{bit_val}};
        if (result == 32'hFFFFFFFF) pass_count++;
        
        // Test 2: Replicate zero
        test_count++;
        bit_val = 1'b0;
        result = {32{bit_val}};
        if (result == 32'h0) pass_count++;
        
        // Test 3: Replicate byte
        test_count++;
        byte_val = 8'hAB;
        result = {4{byte_val}};
        if (result == 32'hABABABAB) pass_count++;
        
        // Test 4: Replicate nibble
        test_count++;
        nibble = 4'h5;
        result = {8{nibble}};
        if (result == 32'h55555555) pass_count++;
        
        // Test 5: Replicate pattern
        test_count++;
        result = {16{2'b10}};
        if (result == 32'hAAAAAAAA) pass_count++;
        
        // Test 6: Single replication
        test_count++;
        result = {1{32'h12345678}};
        if (result == 32'h12345678) pass_count++;
        
        // Test 7: Two replications
        test_count++;
        result = {2{16'hABCD}};
        if (result == 32'hABCDABCD) pass_count++;
        
        // Test 8: Nested replication
        test_count++;
        result = {2{{2{8'hF0}}}};
        if (result == 32'hF0F0F0F0) pass_count++;
        
        // Test 9: Replication in expression
        test_count++;
        result = {4{byte_val}} & 32'h0F0F0F0F;
        if (result == 32'h0B0B0B0B) pass_count++;
        
        // Test 10: Replication concat
        test_count++;
        result = {{2{8'hAA}}, {2{8'h55}}};
        if (result == 32'hAAAA5555) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
