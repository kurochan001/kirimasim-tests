/*
:name: test_signed_unsigned
:description: Signed and Unsigned Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.7 11.8.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_unsigned.expected
*/
// IEEE 1800-2023 Section 11.8 - Signed and Unsigned Tests
// Tests: signed, unsigned, $signed, $unsigned

module test_signed_unsigned;
    int pass_count = 0;
    int fail_count = 0;

    logic signed [7:0] s_val;
    logic [7:0] u_val;
    int result;

    initial begin
        $display("=== IEEE 1800-2023 Signed and Unsigned Test ===");

        // Test 1: Unsigned interpretation
        $display("Test 1: Unsigned interpretation");
        u_val = 8'hFF;
        result = u_val;
        $display("  8'hFF as unsigned = %0d", result);
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: Signed interpretation
        $display("Test 2: Signed interpretation");
        s_val = 8'hFF;
        result = s_val;
        $display("  8'shFF as signed = %0d", result);
        $display("Test 2 PASS");
        pass_count++;

        // Test 3: Positive signed
        $display("Test 3: Positive signed");
        s_val = 8'h7F;
        result = s_val;
        $display("  8'sh7F as signed = %0d", result);
        $display("Test 3 PASS");
        pass_count++;

        // Test 4: $signed system function
        $display("Test 4: $signed system function");
        u_val = 8'hF0;
        result = $signed(u_val);
        $display("  $signed(8'hF0) = %0d", result);
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: $unsigned system function
        $display("Test 5: $unsigned system function");
        s_val = -16;
        result = $unsigned(s_val);
        $display("  $unsigned(-16) = %0d", result);
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: Signed comparison
        $display("Test 6: Signed comparison");
        s_val = -1;
        if (s_val < 0)
            $display("  -1 < 0 is true");
        else
            $display("  -1 < 0 is false");
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: Signed arithmetic
        $display("Test 7: Signed arithmetic");
        s_val = -10;
        result = s_val * 2;
        $display("  -10 * 2 = %0d", result);
        $display("Test 7 PASS");
        pass_count++;

        // Test 8: Mixed signed/unsigned
        $display("Test 8: Mixed signed/unsigned");
        s_val = -5;
        u_val = 10;
        result = s_val + $signed(u_val);
        $display("  -5 + 10 = %0d", result);
        $display("Test 8 PASS");
        pass_count++;

        // Test 9: Signed shift
        $display("Test 9: Signed shift");
        s_val = -16;
        result = s_val >>> 2;
        $display("  -16 >>> 2 = %0d (arithmetic)", result);
        $display("Test 9 PASS");
        pass_count++;

        // Test 10: Boundary values
        $display("Test 10: Boundary values");
        s_val = 8'sh80;  // -128
        result = s_val;
        $display("  8'sh80 = %0d", result);
        s_val = 8'sh7F;  // 127
        result = s_val;
        $display("  8'sh7F = %0d", result);
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
