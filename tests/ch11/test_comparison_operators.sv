/*
:name: test_comparison_operators
:description: Comparison Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4 11.4.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comparison_operators.expected
*/
// IEEE 1800-2023 Section 11.4.5 - Comparison Operators Tests
// Tests: ==, !=, ===, !==, <, >, <=, >=

module test_comparison_operators;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] a, b;
    logic [7:0] x_val;
    logic result;

    initial begin
        $display("=== IEEE 1800-2023 Comparison Operators Test ===");

        // Test 1: Equal ==
        $display("Test 1: Equal ==");
        a = 8'h55;
        b = 8'h55;
        result = (a == b);
        $display("  8'h55 == 8'h55 = %b", result);
        a = 8'h55;
        b = 8'hAA;
        result = (a == b);
        $display("  8'h55 == 8'hAA = %b", result);
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: Not equal !=
        $display("Test 2: Not equal !=");
        a = 8'h55;
        b = 8'hAA;
        result = (a != b);
        $display("  8'h55 != 8'hAA = %b", result);
        $display("Test 2 PASS");
        pass_count++;

        // Test 3: Case equal ===
        $display("Test 3: Case equal ===");
        a = 8'h55;
        b = 8'h55;
        result = (a === b);
        $display("  8'h55 === 8'h55 = %b", result);
        $display("Test 3 PASS");
        pass_count++;

        // Test 4: Case not equal !==
        $display("Test 4: Case not equal !==");
        a = 8'h55;
        b = 8'hAA;
        result = (a !== b);
        $display("  8'h55 !== 8'hAA = %b", result);
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: Less than <
        $display("Test 5: Less than <");
        a = 8'h10;
        b = 8'h20;
        result = (a < b);
        $display("  8'h10 < 8'h20 = %b", result);
        result = (b < a);
        $display("  8'h20 < 8'h10 = %b", result);
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: Greater than >
        $display("Test 6: Greater than >");
        a = 8'h30;
        b = 8'h20;
        result = (a > b);
        $display("  8'h30 > 8'h20 = %b", result);
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: Less than or equal <=
        $display("Test 7: Less than or equal <=");
        a = 8'h10;
        b = 8'h10;
        result = (a <= b);
        $display("  8'h10 <= 8'h10 = %b", result);
        a = 8'h05;
        result = (a <= b);
        $display("  8'h05 <= 8'h10 = %b", result);
        $display("Test 7 PASS");
        pass_count++;

        // Test 8: Greater than or equal >=
        $display("Test 8: Greater than or equal >=");
        a = 8'h20;
        b = 8'h20;
        result = (a >= b);
        $display("  8'h20 >= 8'h20 = %b", result);
        a = 8'h30;
        result = (a >= b);
        $display("  8'h30 >= 8'h20 = %b", result);
        $display("Test 8 PASS");
        pass_count++;

        // Test 9: Comparison chain
        $display("Test 9: Comparison chain");
        a = 8'h15;
        result = (a > 8'h10) && (a < 8'h20);
        $display("  10 < 15 < 20 = %b", result);
        $display("Test 9 PASS");
        pass_count++;

        // Test 10: Zero comparison
        $display("Test 10: Zero comparison");
        a = 8'h00;
        result = (a == 0);
        $display("  0 == 0 = %b", result);
        result = (a > 0);
        $display("  0 > 0 = %b", result);
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
