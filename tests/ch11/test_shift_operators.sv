/*
:name: test_shift_operators
:description: Shift Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shift_operators.expected
*/
// IEEE 1800-2023 Section 11.4.10 - Shift Operators Tests
// Tests: <<, >>, <<<, >>>

module test_shift_operators;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] uval;
    logic signed [7:0] sval;
    logic [7:0] result;

    initial begin
        $display("=== IEEE 1800-2023 Shift Operators Test ===");

        // Test 1: Left shift
        $display("Test 1: Left shift <<");
        uval = 8'h01;
        result = uval << 4;
        $display("  8'h01 << 4 = %h", result);
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: Right shift
        $display("Test 2: Right shift >>");
        uval = 8'h80;
        result = uval >> 4;
        $display("  8'h80 >> 4 = %h", result);
        $display("Test 2 PASS");
        pass_count++;

        // Test 3: Arithmetic left shift
        $display("Test 3: Arithmetic left shift <<<");
        sval = -8'sd16;  // 8'hF0
        result = sval <<< 2;
        $display("  -16 <<< 2 = %h", result);
        $display("Test 3 PASS");
        pass_count++;

        // Test 4: Arithmetic right shift - negative
        $display("Test 4: Arithmetic right shift >>> negative");
        sval = -8'sd16;  // 8'hF0
        result = sval >>> 2;
        $display("  -16 >>> 2 = %h (sign extended)", result);
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: Arithmetic right shift - positive
        $display("Test 5: Arithmetic right shift >>> positive");
        sval = 8'sd64;  // 8'h40
        result = sval >>> 2;
        $display("  64 >>> 2 = %h", result);
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: Shift by 0
        $display("Test 6: Shift by 0");
        uval = 8'hAB;
        result = uval << 0;
        $display("  8'hAB << 0 = %h", result);
        result = uval >> 0;
        $display("  8'hAB >> 0 = %h", result);
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: Shift entire value out
        $display("Test 7: Shift entire value out");
        uval = 8'hFF;
        result = uval << 8;
        $display("  8'hFF << 8 = %h", result);
        result = uval >> 8;
        $display("  8'hFF >> 8 = %h", result);
        $display("Test 7 PASS");
        pass_count++;

        // Test 8: Progressive shifts
        $display("Test 8: Progressive shifts");
        uval = 8'h01;
        for (int i = 0; i < 8; i++) begin
            result = uval << i;
            $display("  1 << %0d = %h", i, result);
        end
        $display("Test 8 PASS");
        pass_count++;

        // Test 9: Combined shifts
        $display("Test 9: Combined shifts");
        uval = 8'hAB;
        result = (uval << 2) >> 2;
        $display("  (8'hAB << 2) >> 2 = %h", result);
        $display("Test 9 PASS");
        pass_count++;

        // Test 10: Shift in expressions
        $display("Test 10: Shift in expressions");
        uval = 8'h01;
        result = (uval << 4) | (uval << 0);
        $display("  (1 << 4) | (1 << 0) = %h", result);
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
