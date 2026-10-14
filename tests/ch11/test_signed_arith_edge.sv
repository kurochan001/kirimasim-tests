/*
:name: test_signed_arith_edge
:description: Test: Signed arithmetic edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.4 6.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_arith_edge.expected
*/
// Test: Signed arithmetic edge cases

module test_signed_arith_edge;
    int pass_count = 0;
    int test_count = 0;
    
    // Signed variables
    int signed_a, signed_b, signed_result;
    shortint short_a, short_b;
    longint long_a, long_b;
    
    initial begin
        // Test 1: Maximum positive value
        test_count++;
        signed_a = 32'h7FFFFFFF; // 2147483647
        if (signed_a > 0) pass_count++;
        
        // Test 2: Minimum negative value
        test_count++;
        signed_b = 32'h80000000; // -2147483648
        if (signed_b < 0) pass_count++;
        
        // Test 3: Signed comparison
        test_count++;
        if (signed_b < signed_a) pass_count++;
        
        // Test 4: Signed addition near overflow
        test_count++;
        signed_a = 32'h7FFFFFFE;
        signed_result = signed_a + 1;
        if (signed_result == 32'h7FFFFFFF) pass_count++;
        
        // Test 5: Signed subtraction near underflow
        test_count++;
        signed_b = 32'h80000001;
        signed_result = signed_b - 1;
        if (signed_result == 32'h80000000) pass_count++;
        
        // Test 6: Shortint boundary
        test_count++;
        short_a = 16'h7FFF;
        short_b = 16'h8000;
        if (short_a > short_b) pass_count++;
        
        // Test 7: Longint operations
        test_count++;
        long_a = 64'h7FFFFFFFFFFFFFFF;
        if (long_a > 0) pass_count++;
        
        // Test 8: Sign extension in assignment
        test_count++;
        signed_a = -1;
        long_a = signed_a;
        if (long_a == -1) pass_count++;
        
        // Test 9: Multiplication overflow
        test_count++;
        signed_a = 32'h7FFF;
        signed_b = 32'h10000;
        signed_result = signed_a * signed_b;
        if (signed_result != 0) pass_count++;
        
        // Test 10: Division with negative
        test_count++;
        signed_a = -100;
        signed_b = 7;
        signed_result = signed_a / signed_b;
        if (signed_result == -14) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
