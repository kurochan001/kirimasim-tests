/*
:name: test_reduction_edge
:description: Test: Reduction operation edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reduction_edge.expected
*/
// Test: Reduction operation edge cases
module test_reduction_edge;
    int pass_count = 0;
    int test_count = 0;
    
    logic [31:0] a;
    logic [0:0] single;
    logic result;
    
    initial begin
        // Test 1: AND reduction all ones
        test_count++;
        a = 32'hFFFFFFFF;
        result = &a;
        if (result == 1) pass_count++;
        
        // Test 2: AND reduction has zero
        test_count++;
        a = 32'hFFFFFFFE;
        result = &a;
        if (result == 0) pass_count++;
        
        // Test 3: OR reduction all zeros
        test_count++;
        a = 32'h0;
        result = |a;
        if (result == 0) pass_count++;
        
        // Test 4: OR reduction has one
        test_count++;
        a = 32'h00000001;
        result = |a;
        if (result == 1) pass_count++;
        
        // Test 5: XOR reduction even ones
        test_count++;
        a = 32'h0000000F; // 4 ones
        result = ^a;
        if (result == 0) pass_count++;
        
        // Test 6: XOR reduction odd ones
        test_count++;
        a = 32'h00000007; // 3 ones
        result = ^a;
        if (result == 1) pass_count++;
        
        // Test 7: NAND reduction
        test_count++;
        a = 32'hFFFFFFFF;
        result = ~&a;
        if (result == 0) pass_count++;
        
        // Test 8: NOR reduction
        test_count++;
        a = 32'h0;
        result = ~|a;
        if (result == 1) pass_count++;
        
        // Test 9: Single bit reduction
        test_count++;
        single = 1'b1;
        result = &single;
        if (result == 1) pass_count++;
        
        // Test 10: XNOR reduction
        test_count++;
        a = 32'h0000000F;
        result = ~^a;
        if (result == 1) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
