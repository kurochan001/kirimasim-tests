/*
:name: test_bitwise_operators
:description: Bitwise Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitwise_operators.expected
*/
// IEEE 1800-2023 Section 11.4 - Bitwise Operators Tests
// Tests: &, |, ^, ~

module test_bitwise_operators;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] a, b, result;

    initial begin
        $display("=== IEEE 1800-2023 Bitwise Operators Test ===");

        // Test 1: Bitwise AND
        $display("Test 1: Bitwise AND");
        a = 8'hF0;
        b = 8'h0F;
        result = a & b;
        $display("  F0 & 0F = %h", result);
        a = 8'hFF;
        b = 8'hAA;
        result = a & b;
        $display("  FF & AA = %h", result);
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: Bitwise OR
        $display("Test 2: Bitwise OR");
        a = 8'hF0;
        b = 8'h0F;
        result = a | b;
        $display("  F0 | 0F = %h", result);
        $display("Test 2 PASS");
        pass_count++;

        // Test 3: Bitwise XOR
        $display("Test 3: Bitwise XOR");
        a = 8'hFF;
        b = 8'hAA;
        result = a ^ b;
        $display("  FF ^ AA = %h", result);
        $display("Test 3 PASS");
        pass_count++;

        // Test 4: Bitwise NOT
        $display("Test 4: Bitwise NOT");
        a = 8'hAA;
        result = ~a;
        $display("  ~AA = %h", result);
        a = 8'h00;
        result = ~a;
        $display("  ~00 = %h", result);
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: Combined operations
        $display("Test 5: Combined operations");
        a = 8'hF0;
        b = 8'h0F;
        result = (a | b) & 8'hFF;
        $display("  (F0 | 0F) & FF = %h", result);
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: XOR self
        $display("Test 6: XOR self");
        a = 8'hAB;
        result = a ^ a;
        $display("  AB ^ AB = %h", result);
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: Mask operation
        $display("Test 7: Mask operation");
        a = 8'hCD;
        result = a & 8'h0F;  // low nibble
        $display("  CD & 0F = %h", result);
        result = a & 8'hF0;  // high nibble
        $display("  CD & F0 = %h", result);
        $display("Test 7 PASS");
        pass_count++;

        // Test 8: Set bits
        $display("Test 8: Set bits");
        a = 8'h00;
        result = a | 8'h81;  // set MSB and LSB
        $display("  00 | 81 = %h", result);
        $display("Test 8 PASS");
        pass_count++;

        // Test 9: Toggle bits
        $display("Test 9: Toggle bits");
        a = 8'hAA;
        result = a ^ 8'hFF;  // toggle all
        $display("  AA ^ FF = %h", result);
        $display("Test 9 PASS");
        pass_count++;

        // Test 10: Complex expression
        $display("Test 10: Complex expression");
        a = 8'h12;
        b = 8'h34;
        result = (~a & b) | (a & ~b);  // XOR via AND/OR
        $display("  (~12 & 34) | (12 & ~34) = %h", result);
        $display("Test 10 PASS");
        pass_count++;

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
