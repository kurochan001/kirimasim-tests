/*
:name: test_binary_arith
:description: Binary Arithmetic Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_binary_arith.expected
*/
// IEEE 1800-2023 Section 11.4.1 - Binary Arithmetic Tests
module test_binary_arith;
    int pass_count = 0;
    int fail_count = 0;
    
    initial begin
        int a, b, result;
        
        $display("=== IEEE 1800-2023 Binary Arithmetic Tests ===");
        
        // Test 1: Add
        $display("Test 1: Add");
        a = 10; b = 20;
        result = a + b;
        if (result == 30) begin $display("Test 1 PASS: %0d", result); pass_count++; end
        else begin $display("Test 1 FAIL: got %0d", result); fail_count++; end
        
        // Test 2: Subtract
        $display("Test 2: Sub");
        result = b - a;
        if (result == 10) begin $display("Test 2 PASS: %0d", result); pass_count++; end
        else begin $display("Test 2 FAIL: got %0d", result); fail_count++; end
        
        // Test 3: Multiply
        $display("Test 3: Mult");
        result = a * b;
        if (result == 200) begin $display("Test 3 PASS: %0d", result); pass_count++; end
        else begin $display("Test 3 FAIL: got %0d", result); fail_count++; end
        
        // Test 4: Divide
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
        
        // Test 6: Power
        $display("Test 6: Power");
        result = 2 ** 4;
        if (result == 16) begin $display("Test 6 PASS: %0d", result); pass_count++; end
        else begin $display("Test 6 FAIL: got %0d", result); fail_count++; end
        
        // Test 7: Negative sub
        $display("Test 7: Neg sub");
        a = 5; b = 10;
        result = a - b;
        if (result == -5) begin $display("Test 7 PASS: %0d", result); pass_count++; end
        else begin $display("Test 7 FAIL: got %0d", result); fail_count++; end
        
        // Test 8: Zero mult
        $display("Test 8: Zero mult");
        result = 999 * 0;
        if (result == 0) begin $display("Test 8 PASS: %0d", result); pass_count++; end
        else begin $display("Test 8 FAIL: got %0d", result); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
