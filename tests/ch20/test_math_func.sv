/*
:name: test_math_func
:description: Real math system functions with exact results
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2 20.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_func.expected
*/
// Real math system functions with exact results
module test_math_func;
    int pass_count = 0;
    int test_count = 0;
    real r1, r2, result;
    int ival;
    
    initial begin
        // Test 1: $sqrt
        test_count++;
        r1 = 16.0;
        result = $sqrt(r1);
        if (result == 4.0) pass_count++;
        
        // Test 2: $pow
        test_count++;
        result = $pow(2.0, 10.0);
        if (result == 1024.0) pass_count++;
        
        // Test 3: $exp
        test_count++;
        result = $exp(0.0);
        if (result == 1.0) pass_count++;
        
        // Test 4: $ln
        test_count++;
        result = $ln(1.0);
        if (result == 0.0) pass_count++;
        
        // Test 5: $log10
        test_count++;
        result = $log10(100.0);
        if (result == 2.0) pass_count++;
        
        // Test 6: $floor
        test_count++;
        result = $floor(3.7);
        if (result == 3.0) pass_count++;
        
        // Test 7: $ceil
        test_count++;
        result = $ceil(3.1);
        if (result == 4.0) pass_count++;
        
        // Test 8: $sin/$cos
        test_count++;
        result = $sin(0.0);
        if (result == 0.0) pass_count++;
        
        // Test 9: $abs
        test_count++;
        r1 = -5.5;
        result = (r1 < 0) ? -r1 : r1;
        if (result == 5.5) pass_count++;
        
        // Test 10: $rtoi
        test_count++;
        r1 = 42.9;
        ival = $rtoi(r1);
        if (ival == 42) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
