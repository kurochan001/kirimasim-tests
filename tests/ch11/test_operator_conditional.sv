/*
:name: test_operator_conditional
:description: Conditional operator ?: test
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_conditional.expected
*/
// Conditional operator ?: test
module test_operator_conditional;
    int a, b, result;
    logic cond;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Basic true condition
        a = 10; b = 20; cond = 1;
        result = cond ? a : b;
        if (result == 10) begin
            $display("PASS: true ? 10 : 20 = 10");
            pass_count++;
        end else begin
            $display("FAIL: true ? 10 : 20, expected 10, got %0d", result);
            fail_count++;
        end

        // Test 2: Basic false condition
        cond = 0;
        result = cond ? a : b;
        if (result == 20) begin
            $display("PASS: false ? 10 : 20 = 20");
            pass_count++;
        end else begin
            $display("FAIL: false ? 10 : 20, expected 20, got %0d", result);
            fail_count++;
        end

        // Test 3: Nested conditional
        a = 5; b = 15;
        result = (a > b) ? 100 : ((a < 10) ? 200 : 300);
        if (result == 200) begin
            $display("PASS: Nested conditional = 200");
            pass_count++;
        end else begin
            $display("FAIL: Nested conditional, expected 200, got %0d", result);
            fail_count++;
        end

        // Test 4: Conditional with expressions
        a = 8; b = 4;
        result = (a + b > 10) ? (a * 2) : (b * 3);
        if (result == 16) begin
            $display("PASS: (12 > 10) ? 16 : 12 = 16");
            pass_count++;
        end else begin
            $display("FAIL: Conditional with expressions, expected 16, got %0d", result);
            fail_count++;
        end

        // Test 5: Chained conditional
        a = 50;
        result = (a < 25) ? 1 : (a < 75) ? 2 : 3;
        if (result == 2) begin
            $display("PASS: Chained conditional for 50 = 2");
            pass_count++;
        end else begin
            $display("FAIL: Chained conditional, expected 2, got %0d", result);
            fail_count++;
        end

        // Summary
        $display("Conditional operators: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All conditional operator tests passed");
        else $display("FAIL: Some conditional operator tests failed");
        $finish;
    end
endmodule
