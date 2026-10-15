/*
:name: test_expr
:description: Arithmetic, bitwise, shift and conditional expressions (IEEE 1800-2023 Section 11.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.8 11.4.10 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr.expected
*/
// Arithmetic, bitwise, shift and conditional expressions (IEEE 1800-2023 Section 11.4)
module test_expr;
    int pass_count = 0;
    int test_count = 0;
    logic [31:0] a, b, c, d;
    int x, y, z;
    
    initial begin
        // Initialize
        a = 32'h12345678;
        b = 32'hABCDEF01;
        x = 100;
        y = 200;
        
        // Test 1: Add
        test_count++;
        c = a + b;
        if (c == (a + b)) pass_count++;
        
        // Test 2: Sub
        test_count++;
        c = b - a;
        if (c == (b - a)) pass_count++;
        
        // Test 3: Mul
        test_count++;
        z = x * y;
        if (z == 20000) pass_count++;
        
        // Test 4: Div
        test_count++;
        z = y / x;
        if (z == 2) pass_count++;
        
        // Test 5: Mod
        test_count++;
        z = y % x;
        if (z == 0) pass_count++;
        
        // Test 6: Complex expression
        test_count++;
        z = (x + y) * 2 - x;
        if (z == 500) pass_count++;
        
        // Test 7: Bitwise expression
        test_count++;
        c = (a & b) | (a ^ b);
        if (c == (a | b)) pass_count++;
        
        // Test 8: Shift expression
        test_count++;
        c = (a << 4) >> 4;
        if (c == (a & 32'h0FFFFFFF)) pass_count++;
        
        // Test 9: Comparison chain
        test_count++;
        if (x < y && y < 300 && x > 0) pass_count++;
        
        // Test 10: Ternary chain
        test_count++;
        z = (x > 200) ? 1 : (x > 100) ? 2 : (x > 50) ? 3 : 4;
        if (z == 3) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
