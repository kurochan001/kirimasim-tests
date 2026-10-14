/*
:name: test_bitwise_basic
:description: Bitwise Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitwise_basic.expected
*/
// IEEE 1800-2023 Section 11.4.8 - Bitwise Operators Tests
module test_bitwise_basic;
    int pass_count = 0;
    int fail_count = 0;
    
    initial begin
        logic [7:0] a, b, result;
        
        $display("=== IEEE 1800-2023 Bitwise Operators Tests ===");
        
        // Test 1: AND
        $display("Test 1: AND");
        a = 8'hF0; b = 8'h0F;
        result = a & b;
        if (result == 8'h00) begin $display("Test 1 PASS: %h", result); pass_count++; end
        else begin $display("Test 1 FAIL: got %h", result); fail_count++; end
        
        // Test 2: OR
        $display("Test 2: OR");
        result = a | b;
        if (result == 8'hFF) begin $display("Test 2 PASS: %h", result); pass_count++; end
        else begin $display("Test 2 FAIL: got %h", result); fail_count++; end
        
        // Test 3: XOR
        $display("Test 3: XOR");
        a = 8'hAA; b = 8'h55;
        result = a ^ b;
        if (result == 8'hFF) begin $display("Test 3 PASS: %h", result); pass_count++; end
        else begin $display("Test 3 FAIL: got %h", result); fail_count++; end
        
        // Test 4: NOT
        $display("Test 4: NOT");
        result = ~8'hAA;
        if (result == 8'h55) begin $display("Test 4 PASS: %h", result); pass_count++; end
        else begin $display("Test 4 FAIL: got %h", result); fail_count++; end
        
        // Test 5: AND same
        $display("Test 5: AND same");
        a = 8'hFF;
        result = a & a;
        if (result == 8'hFF) begin $display("Test 5 PASS: %h", result); pass_count++; end
        else begin $display("Test 5 FAIL: got %h", result); fail_count++; end
        
        // Test 6: OR with zero
        $display("Test 6: OR zero");
        result = a | 8'h00;
        if (result == 8'hFF) begin $display("Test 6 PASS: %h", result); pass_count++; end
        else begin $display("Test 6 FAIL: got %h", result); fail_count++; end
        
        // Test 7: XOR same
        $display("Test 7: XOR same");
        result = a ^ a;
        if (result == 8'h00) begin $display("Test 7 PASS: %h", result); pass_count++; end
        else begin $display("Test 7 FAIL: got %h", result); fail_count++; end
        
        // Test 8: Complex
        $display("Test 8: Complex");
        a = 8'h12; b = 8'h34;
        result = (a & b) | (a ^ b);
        if (result == (a | b)) begin $display("Test 8 PASS: %h", result); pass_count++; end
        else begin $display("Test 8 FAIL: got %h", result); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
