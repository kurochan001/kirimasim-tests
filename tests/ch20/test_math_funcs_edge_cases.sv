/*
:name: test_math_funcs_edge_cases
:description: Math functions edge cases
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_funcs_edge_cases.expected
*/
// IEEE 1800-2023 §20.8: Math functions edge cases
// Tests for math system functions

module test_math_funcs_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    real r1, r2, result;

    initial begin
        // Test 1: $ln
        test_count++;
        result = $ln(2.718281828);
        if (result > 0.99 && result < 1.01) begin
            pass_count++;
            $display("Test 1 PASS: $ln(e) = %f", result);
        end else begin
            $display("Test 1 FAIL: ln unexpected = %f", result);
        end

        // Test 2: $log10
        test_count++;
        result = $log10(100.0);
        if (result > 1.99 && result < 2.01) begin
            pass_count++;
            $display("Test 2 PASS: $log10(100) = %f", result);
        end else begin
            $display("Test 2 FAIL: log10 unexpected = %f", result);
        end

        // Test 3: $exp
        test_count++;
        result = $exp(1.0);
        if (result > 2.71 && result < 2.72) begin
            pass_count++;
            $display("Test 3 PASS: $exp(1) = %f", result);
        end else begin
            $display("Test 3 FAIL: exp unexpected = %f", result);
        end

        // Test 4: $sqrt
        test_count++;
        result = $sqrt(16.0);
        if (result == 4.0) begin
            pass_count++;
            $display("Test 4 PASS: $sqrt(16) = %f", result);
        end else begin
            $display("Test 4 FAIL: sqrt unexpected = %f", result);
        end

        // Test 5: $pow
        test_count++;
        result = $pow(2.0, 10.0);
        if (result > 1024.0 - 1e-9 && result < 1024.0 + 1e-9) begin
            pass_count++;
            $display("Test 5 PASS: $pow(2,10) = %f", result);
        end else begin
            $display("Test 5 FAIL: pow unexpected = %f", result);
        end

        // Test 6: $floor
        test_count++;
        result = $floor(3.7);
        if (result == 3.0) begin
            pass_count++;
            $display("Test 6 PASS: $floor(3.7) = %f", result);
        end else begin
            $display("Test 6 FAIL: floor unexpected = %f", result);
        end

        // Test 7: $ceil
        test_count++;
        result = $ceil(3.2);
        if (result == 4.0) begin
            pass_count++;
            $display("Test 7 PASS: $ceil(3.2) = %f", result);
        end else begin
            $display("Test 7 FAIL: ceil unexpected = %f", result);
        end

        // Test 8: $sin
        test_count++;
        result = $sin(0.0);
        if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
            pass_count++;
            $display("Test 8 PASS: $sin(0) = %f", result);
        end else begin
            $display("Test 8 FAIL: sin unexpected = %f", result);
        end

        // Test 9: $cos
        test_count++;
        result = $cos(0.0);
        if (result > 1.0 - 1e-9 && result < 1.0 + 1e-9) begin
            pass_count++;
            $display("Test 9 PASS: $cos(0) = %f", result);
        end else begin
            $display("Test 9 FAIL: cos unexpected = %f", result);
        end

        // Test 10: $tan
        test_count++;
        result = $tan(0.0);
        if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
            pass_count++;
            $display("Test 10 PASS: $tan(0) = %f", result);
        end else begin
            $display("Test 10 FAIL: tan unexpected = %f", result);
        end

        // Test 11: $asin
        test_count++;
        result = $asin(0.0);
        if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
            pass_count++;
            $display("Test 11 PASS: $asin(0) = %f", result);
        end else begin
            $display("Test 11 FAIL: asin unexpected = %f", result);
        end

        // Test 12: $acos
        test_count++;
        result = $acos(1.0);
        if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
            pass_count++;
            $display("Test 12 PASS: $acos(1) = %f", result);
        end else begin
            $display("Test 12 FAIL: acos unexpected = %f", result);
        end

        // Test 13: $atan
        test_count++;
        result = $atan(0.0);
        if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
            pass_count++;
            $display("Test 13 PASS: $atan(0) = %f", result);
        end else begin
            $display("Test 13 FAIL: atan unexpected = %f", result);
        end

        // Test 14: $atan2
        test_count++;
        result = $atan2(0.0, 1.0);
        if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
            pass_count++;
            $display("Test 14 PASS: $atan2(0,1) = %f", result);
        end else begin
            $display("Test 14 FAIL: atan2 unexpected = %f", result);
        end

        // Test 15: $hypot
        test_count++;
        result = $hypot(3.0, 4.0);
        if (result > 5.0 - 1e-9 && result < 5.0 + 1e-9) begin
            pass_count++;
            $display("Test 15 PASS: $hypot(3,4) = %f", result);
        end else begin
            $display("Test 15 FAIL: hypot unexpected = %f", result);
        end

        $display("=== Math Funcs Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
