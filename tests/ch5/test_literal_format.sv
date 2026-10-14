/*
:name: test_literal_format
:description: Literal Format Tests
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1 21.2.1.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_literal_format.expected
*/
// IEEE 1800-2023 Section 5.7 - Literal Format Tests
module test_literal_format;
    int pass_count = 0;
    int fail_count = 0;
    
    initial begin
        logic [31:0] val;
        
        $display("=== IEEE 1800-2023 Literal Format Tests ===");
        
        // Test 1: Decimal literal
        $display("Test 1: Decimal");
        val = 100;
        if (val == 100) begin $display("Test 1 PASS: %0d", val); pass_count++; end
        else begin $display("Test 1 FAIL: got %0d", val); fail_count++; end
        
        // Test 2: Hex literal
        $display("Test 2: Hex");
        val = 32'hABCD;
        if (val == 43981) begin $display("Test 2 PASS: %h", val); pass_count++; end
        else begin $display("Test 2 FAIL: got %h", val); fail_count++; end
        
        // Test 3: Binary literal
        $display("Test 3: Binary");
        val = 8'b10101010;
        if (val == 170) begin $display("Test 3 PASS: %b", val); pass_count++; end
        else begin $display("Test 3 FAIL: got %b", val); fail_count++; end
        
        // Test 4: Octal literal
        $display("Test 4: Octal");
        val = 8'o77;
        if (val == 63) begin $display("Test 4 PASS: %o", val); pass_count++; end
        else begin $display("Test 4 FAIL: got %o", val); fail_count++; end
        
        // Test 5: Sized decimal
        $display("Test 5: Sized dec");
        val = 8'd255;
        if (val == 255) begin $display("Test 5 PASS: %0d", val); pass_count++; end
        else begin $display("Test 5 FAIL: got %0d", val); fail_count++; end
        
        // Test 6: Unsized decimal
        $display("Test 6: Unsized");
        val = 'd1000;
        if (val == 1000) begin $display("Test 6 PASS: %0d", val); pass_count++; end
        else begin $display("Test 6 FAIL: got %0d", val); fail_count++; end
        
        // Test 7: Zero literal
        $display("Test 7: Zero");
        val = 0;
        if (val == 0) begin $display("Test 7 PASS: %0d", val); pass_count++; end
        else begin $display("Test 7 FAIL: got %0d", val); fail_count++; end
        
        // Test 8: Large literal
        $display("Test 8: Large");
        val = 32'hFFFFFFFF;
        if (val == 32'hFFFFFFFF) begin $display("Test 8 PASS: %h", val); pass_count++; end
        else begin $display("Test 8 FAIL: got %h", val); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
