/*
:name: test_shift_corner
:description: Test: Shift operation corner cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shift_corner.expected
*/
// Test: Shift operation corner cases
module test_shift_corner;
    int pass_count = 0;
    int test_count = 0;
    
    logic [31:0] a, result;
    logic signed [31:0] sa, sresult;
    
    initial begin
        // Test 1: Left shift by 0
        test_count++;
        a = 32'hABCD1234;
        result = a << 0;
        if (result == a) pass_count++;
        
        // Test 2: Right shift by 0
        test_count++;
        result = a >> 0;
        if (result == a) pass_count++;
        
        // Test 3: Left shift by width
        test_count++;
        result = a << 32;
        if (result == 0) pass_count++;
        
        // Test 4: Right shift by width
        test_count++;
        result = a >> 32;
        if (result == 0) pass_count++;
        
        // Test 5: Arithmetic right shift positive
        test_count++;
        sa = 32'h7FFFFFFF;
        sresult = sa >>> 4;
        if (sresult == 32'h07FFFFFF) pass_count++;
        
        // Test 6: Arithmetic right shift negative
        test_count++;
        sa = 32'h80000000;
        sresult = sa >>> 4;
        if (sresult == 32'hF8000000) pass_count++;
        
        // Test 7: Shift by 1
        test_count++;
        a = 1;
        result = a << 1;
        if (result == 2) pass_count++;
        
        // Test 8: Large shift amount
        test_count++;
        result = a << 31;
        if (result == 32'h80000000) pass_count++;
        
        // Test 9: Chain shift
        test_count++;
        a = 32'h12345678;
        result = (a << 4) >> 4;
        if (result == 32'h02345678) pass_count++;
        
        // Test 10: Rotate emulation
        test_count++;
        a = 32'hF0000000;
        result = (a << 4) | (a >> 28);
        if (result == 32'h0000000F) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
