/*
:name: test_expr_ternary
:description: Ternary expressions test
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_ternary.expected
*/
// Ternary expressions test
module test_expr_ternary;
    int a, b, c, result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Simple ternary true
        a = 5; b = 10;
        result = (a < b) ? a : b;
        if (result == 5) begin
            $display("PASS: (5<10) ? 5 : 10 = 5");
            pass_count++;
        end else begin
            $display("FAIL: Ternary true, expected 5, got %0d", result);
            fail_count++;
        end

        // Test 2: Simple ternary false
        a = 20; b = 10;
        result = (a < b) ? a : b;
        if (result == 10) begin
            $display("PASS: (20<10) ? 20 : 10 = 10");
            pass_count++;
        end else begin
            $display("FAIL: Ternary false, expected 10, got %0d", result);
            fail_count++;
        end

        // Test 3: Nested ternary
        a = 50;
        result = (a < 25) ? 1 : (a < 75) ? 2 : 3;
        if (result == 2) begin
            $display("PASS: Nested ternary for 50 = 2");
            pass_count++;
        end else begin
            $display("FAIL: Nested ternary, expected 2, got %0d", result);
            fail_count++;
        end

        // Test 4: Ternary with expressions
        a = 3; b = 4; c = 5;
        result = (a*a + b*b == c*c) ? 1 : 0;
        if (result == 1) begin
            $display("PASS: Pythagorean check (3,4,5) = 1");
            pass_count++;
        end else begin
            $display("FAIL: Pythagorean check, expected 1, got %0d", result);
            fail_count++;
        end

        // Summary
        $display("Ternary expressions: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All ternary expression tests passed");
        else $display("FAIL: Some ternary expression tests failed");
        $finish;
    end
endmodule
