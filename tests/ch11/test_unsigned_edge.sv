/*
:name: test_unsigned_edge
:description: Test: Unsigned arithmetic edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.6.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unsigned_edge.expected
*/
// Test: Unsigned arithmetic edge cases
module test_unsigned_edge;
    int pass_count = 0;
    int test_count = 0;
    
    logic [31:0] ua, ub, uresult;
    logic [7:0] byte_a, byte_b;
    logic [63:0] wide_a;
    
    initial begin
        // Test 1: Maximum unsigned value
        test_count++;
        ua = 32'hFFFFFFFF;
        if (ua > 0) pass_count++;
        
        // Test 2: Unsigned wrap on overflow
        test_count++;
        uresult = ua + 1;
        if (uresult == 0) pass_count++;
        
        // Test 3: Unsigned wrap on underflow
        test_count++;
        ua = 0;
        uresult = ua - 1;
        if (uresult == 32'hFFFFFFFF) pass_count++;
        
        // Test 4: Byte boundary
        test_count++;
        byte_a = 8'hFF;
        byte_b = byte_a + 1;
        if (byte_b == 0) pass_count++;
        
        // Test 5: Wide comparison
        test_count++;
        wide_a = 64'hFFFFFFFF_FFFFFFFF;
        if (wide_a != 0) pass_count++;
        
        // Test 6: Zero extension
        test_count++;
        byte_a = 8'hAB;
        ua = byte_a;
        if (ua == 32'h000000AB) pass_count++;
        
        // Test 7: Truncation
        test_count++;
        ua = 32'h12345678;
        byte_a = ua;
        if (byte_a == 8'h78) pass_count++;
        
        // Test 8: Unsigned division
        test_count++;
        ua = 32'hFFFFFFFF;
        ub = 16;
        uresult = ua / ub;
        if (uresult == 32'h0FFFFFFF) pass_count++;
        
        // Test 9: Unsigned modulo
        test_count++;
        uresult = ua % 256;
        if (uresult == 255) pass_count++;
        
        // Test 10: Power of 2 operations
        test_count++;
        ua = 1 << 31;
        if (ua == 32'h80000000) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
