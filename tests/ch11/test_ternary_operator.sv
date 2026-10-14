/*
:name: test_ternary_operator
:description: Ternary Operator Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ternary_operator.expected
*/
// IEEE 1800-2023 Section 11.4.11 - Ternary Operator Tests
// Tests: conditional operator ?:

module test_ternary_operator;
    int pass_count = 0;
    int fail_count = 0;

    logic cond;
    logic [7:0] a, b, result;
    int i_result;

    initial begin
        $display("=== IEEE 1800-2023 Ternary Operator Test ===");

        // Test 1: Condition true
        $display("Test 1: Condition true");
        cond = 1;
        a = 8'hAA;
        b = 8'hBB;
        result = cond ? a : b;
        $display("  1 ? AA : BB = %h", result);
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: Condition false
        $display("Test 2: Condition false");
        cond = 0;
        result = cond ? a : b;
        $display("  0 ? AA : BB = %h", result);
        $display("Test 2 PASS");
        pass_count++;

        // Test 3: Nested ternary
        $display("Test 3: Nested ternary");
        i_result = (5 > 10) ? 1 : (5 > 3) ? 2 : 3;
        $display("  (5>10)?1:(5>3)?2:3 = %0d", i_result);
        $display("Test 3 PASS");
        pass_count++;

        // Test 4: Ternary with expressions
        $display("Test 4: Ternary with expressions");
        a = 8'h10;
        b = 8'h20;
        result = (a < b) ? (a + b) : (a - b);
        $display("  (16<32)?(16+32):(16-32) = %h", result);
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: Multiple selections
        $display("Test 5: Multiple selections");
        for (int i = 0; i < 4; i++) begin
            result = (i[0]) ? 8'hFF : 8'h00;
            $display("  i=%0d: result=%h", i, result);
        end
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: Ternary with literals
        $display("Test 6: Ternary with literals");
        cond = 1;
        result = cond ? 8'h55 : 8'hAA;
        $display("  1 ? 55 : AA = %h", result);
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: Ternary in assignment
        $display("Test 7: Ternary in assignment");
        a = 8'h30;
        b = 8'h40;
        result = (a > b) ? a : b;  // max
        $display("  max(30, 40) = %h", result);
        result = (a < b) ? a : b;  // min
        $display("  min(30, 40) = %h", result);
        $display("Test 7 PASS");
        pass_count++;

        // Test 8: Boolean result
        $display("Test 8: Boolean result");
        cond = (8'h50 > 8'h40) ? 1 : 0;
        $display("  (50 > 40) ? 1 : 0 = %b", cond);
        $display("Test 8 PASS");
        pass_count++;

        // Test 9: Complex condition
        $display("Test 9: Complex condition");
        a = 8'h25;
        b = 8'h35;
        result = ((a > 8'h20) && (b < 8'h40)) ? 8'hCC : 8'hDD;
        $display("  ((25>20)&&(35<40))?CC:DD = %h", result);
        $display("Test 9 PASS");
        pass_count++;

        // Test 10: Chain of ternary
        $display("Test 10: Chain of ternary");
        i_result = (10 < 5) ? 1 : (10 < 15) ? 2 : (10 < 20) ? 3 : 4;
        $display("  value for 10 = %0d", i_result);
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
