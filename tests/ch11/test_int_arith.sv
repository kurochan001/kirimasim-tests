/*
:name: test_int_arith
:description: Integer Arithmetic Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_int_arith.expected
*/
// IEEE 1800-2023 Section 11.4 - Integer Arithmetic Tests
module test_int_arith;
    int pass_count = 0;
    int fail_count = 0;
    
    initial begin
        int a, b, result;
        
        $display("=== IEEE 1800-2023 Integer Arithmetic Tests ===");
        
        // Test 1: Addition
        $display("Test 1: Add");
        a = 100; b = 50;
        result = a + b;
        if (result == 150) begin $display("Test 1 PASS: %0d", result); pass_count++; end
        else begin $display("Test 1 FAIL: got %0d", result); fail_count++; end
        
        // Test 2: Subtraction
        $display("Test 2: Sub");
        result = a - b;
        if (result == 50) begin $display("Test 2 PASS: %0d", result); pass_count++; end
        else begin $display("Test 2 FAIL: got %0d", result); fail_count++; end
        
        // Test 3: Multiplication
        $display("Test 3: Mult");
        a = 7; b = 6;
        result = a * b;
        if (result == 42) begin $display("Test 3 PASS: %0d", result); pass_count++; end
        else begin $display("Test 3 FAIL: got %0d", result); fail_count++; end
        
        // Test 4: Division
        $display("Test 4: Div");
        a = 100; b = 5;
        result = a / b;
        if (result == 20) begin $display("Test 4 PASS: %0d", result); pass_count++; end
        else begin $display("Test 4 FAIL: got %0d", result); fail_count++; end
        
        // Test 5: Modulo
        $display("Test 5: Mod");
        a = 17; b = 5;
        result = a % b;
        if (result == 2) begin $display("Test 5 PASS: %0d", result); pass_count++; end
        else begin $display("Test 5 FAIL: got %0d", result); fail_count++; end
        
        // Test 6: Negative add
        $display("Test 6: Neg add");
        a = -10; b = 30;
        result = a + b;
        if (result == 20) begin $display("Test 6 PASS: %0d", result); pass_count++; end
        else begin $display("Test 6 FAIL: got %0d", result); fail_count++; end
        
        // Test 7: Zero mult
        $display("Test 7: Zero mult");
        a = 999; b = 0;
        result = a * b;
        if (result == 0) begin $display("Test 7 PASS: %0d", result); pass_count++; end
        else begin $display("Test 7 FAIL: got %0d", result); fail_count++; end
        
        // Test 8: Complex expr
        $display("Test 8: Complex");
        result = 10 + 20 * 3 - 5;
        if (result == 65) begin $display("Test 8 PASS: %0d", result); pass_count++; end
        else begin $display("Test 8 FAIL: got %0d", result); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
