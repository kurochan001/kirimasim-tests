/*
:name: test_comparison_edge
:description: Test: Comparison operation edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4 11.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comparison_edge.expected
*/
// Test: Comparison operation edge cases
module test_comparison_edge;
    int pass_count = 0;
    int test_count = 0;
    
    logic [31:0] a, b;
    int sa, sb;
    
    initial begin
        // Test 1: Equal values
        test_count++;
        a = 32'h12345678;
        b = 32'h12345678;
        if (a == b) pass_count++;
        
        // Test 2: Not equal
        test_count++;
        b = 32'h12345679;
        if (a != b) pass_count++;
        
        // Test 3: Less than unsigned
        test_count++;
        a = 32'h7FFFFFFF;
        b = 32'h80000000;
        if (a < b) pass_count++;
        
        // Test 4: Greater than signed
        test_count++;
        sa = -1;
        sb = 1;
        if (sb > sa) pass_count++;
        
        // Test 5: Less than or equal
        test_count++;
        a = 100;
        b = 100;
        if (a <= b) pass_count++;
        
        // Test 6: Greater than or equal
        test_count++;
        if (a >= b) pass_count++;
        
        // Test 7: Zero comparison
        test_count++;
        a = 0;
        if (a == 0) pass_count++;
        
        // Test 8: Max value comparison
        test_count++;
        a = 32'hFFFFFFFF;
        if (a >= 32'hFFFFFFFE) pass_count++;
        
        // Test 9: Signed zero
        test_count++;
        sa = 0;
        if (sa == 0 && !(sa < 0) && !(sa > 0)) pass_count++;
        
        // Test 10: Chain comparison
        test_count++;
        a = 50;
        b = 100;
        if (a < b && b > a) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
