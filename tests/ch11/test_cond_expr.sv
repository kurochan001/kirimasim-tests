/*
:name: test_cond_expr
:description: Conditional Expression Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cond_expr.expected
*/
// IEEE 1800-2023 Section 11.4.11 - Conditional Expression Tests
module test_cond_expr;
    int pass_count = 0;
    int fail_count = 0;
    
    initial begin
        int a, b, result;
        logic cond;
        
        $display("=== IEEE 1800-2023 Conditional Expression Tests ===");
        
        // Test 1: True condition
        $display("Test 1: True");
        result = 1 ? 100 : 200;
        if (result == 100) begin $display("Test 1 PASS: %0d", result); pass_count++; end
        else begin $display("Test 1 FAIL: got %0d", result); fail_count++; end
        
        // Test 2: False condition
        $display("Test 2: False");
        result = 0 ? 100 : 200;
        if (result == 200) begin $display("Test 2 PASS: %0d", result); pass_count++; end
        else begin $display("Test 2 FAIL: got %0d", result); fail_count++; end
        
        // Test 3: Variable condition
        $display("Test 3: Variable");
        cond = 1;
        result = cond ? 50 : 75;
        if (result == 50) begin $display("Test 3 PASS: %0d", result); pass_count++; end
        else begin $display("Test 3 FAIL: got %0d", result); fail_count++; end
        
        // Test 4: Expression true
        $display("Test 4: Expr true");
        a = 10; b = 5;
        result = (a > b) ? a : b;
        if (result == 10) begin $display("Test 4 PASS: %0d", result); pass_count++; end
        else begin $display("Test 4 FAIL: got %0d", result); fail_count++; end
        
        // Test 5: Expression false
        $display("Test 5: Expr false");
        a = 3; b = 8;
        result = (a > b) ? a : b;
        if (result == 8) begin $display("Test 5 PASS: %0d", result); pass_count++; end
        else begin $display("Test 5 FAIL: got %0d", result); fail_count++; end
        
        // Test 6: Nested true
        $display("Test 6: Nested true");
        result = 1 ? (1 ? 111 : 222) : 333;
        if (result == 111) begin $display("Test 6 PASS: %0d", result); pass_count++; end
        else begin $display("Test 6 FAIL: got %0d", result); fail_count++; end
        
        // Test 7: Nested false
        $display("Test 7: Nested false");
        result = 0 ? 111 : (1 ? 222 : 333);
        if (result == 222) begin $display("Test 7 PASS: %0d", result); pass_count++; end
        else begin $display("Test 7 FAIL: got %0d", result); fail_count++; end
        
        // Test 8: Chain
        $display("Test 8: Chain");
        a = 5;
        result = (a == 1) ? 10 : (a == 5) ? 50 : 0;
        if (result == 50) begin $display("Test 8 PASS: %0d", result); pass_count++; end
        else begin $display("Test 8 FAIL: got %0d", result); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
