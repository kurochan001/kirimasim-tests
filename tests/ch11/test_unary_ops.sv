/*
:name: test_unary_ops
:description: Unary Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unary_ops.expected
*/
// IEEE 1800-2023 Section 11.4.3 - Unary Operators Tests
module test_unary_ops;
    int pass_count = 0;
    int fail_count = 0;
    
    initial begin
        int val;
        logic [7:0] lval;
        
        $display("=== IEEE 1800-2023 Unary Operators Tests ===");
        
        // Test 1: Negation
        $display("Test 1: Negation");
        val = -10;
        if (val == -10) begin $display("Test 1 PASS: %0d", val); pass_count++; end
        else begin $display("Test 1 FAIL: got %0d", val); fail_count++; end
        
        // Test 2: Plus
        $display("Test 2: Plus");
        val = +20;
        if (val == 20) begin $display("Test 2 PASS: %0d", val); pass_count++; end
        else begin $display("Test 2 FAIL: got %0d", val); fail_count++; end
        
        // Test 3: NOT
        $display("Test 3: NOT");
        val = !0;
        if (val == 1) begin $display("Test 3 PASS: %0d", val); pass_count++; end
        else begin $display("Test 3 FAIL: got %0d", val); fail_count++; end
        
        // Test 4: NOT true
        $display("Test 4: NOT true");
        val = !5;
        if (val == 0) begin $display("Test 4 PASS: %0d", val); pass_count++; end
        else begin $display("Test 4 FAIL: got %0d", val); fail_count++; end
        
        // Test 5: Bitwise NOT
        $display("Test 5: Bitwise NOT");
        lval = ~8'h00;
        if (lval == 8'hFF) begin $display("Test 5 PASS: %h", lval); pass_count++; end
        else begin $display("Test 5 FAIL: got %h", lval); fail_count++; end
        
        // Test 6: Bitwise NOT AA
        $display("Test 6: NOT AA");
        lval = ~8'hAA;
        if (lval == 8'h55) begin $display("Test 6 PASS: %h", lval); pass_count++; end
        else begin $display("Test 6 FAIL: got %h", lval); fail_count++; end
        
        // Test 7: Double neg (with parens)
        $display("Test 7: Double neg");
        val = -(-30);
        if (val == 30) begin $display("Test 7 PASS: %0d", val); pass_count++; end
        else begin $display("Test 7 FAIL: got %0d", val); fail_count++; end
        
        // Test 8: Combined
        $display("Test 8: Combined");
        val = !(!1);
        if (val == 1) begin $display("Test 8 PASS: %0d", val); pass_count++; end
        else begin $display("Test 8 FAIL: got %0d", val); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
