/*
:name: test_math_functions
:description: Test for math system functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_functions.expected
*/
// Test for math system functions
// IEEE 1800-2023 §20.8.2

module test_math_functions;
    real result;
    real x, y;
    int pass_count = 0;
    int test_count = 0;
    real tolerance = 0.0001;

    initial begin
        // Test $sqrt
        test_count++;
        result = $sqrt(16.0);
        if (result >= 3.99 && result <= 4.01) begin
            $display("Test 1: $sqrt(16.0) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 1: $sqrt(16.0) = %f FAIL", result);
        end

        // Test $ln (natural log)
        test_count++;
        result = $ln(2.718281828);
        if (result >= 0.99 && result <= 1.01) begin
            $display("Test 2: $ln(e) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 2: $ln(e) = %f FAIL", result);
        end

        // Test $log10
        test_count++;
        result = $log10(100.0);
        if (result >= 1.99 && result <= 2.01) begin
            $display("Test 3: $log10(100) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 3: $log10(100) = %f FAIL", result);
        end

        // Test $exp
        test_count++;
        result = $exp(1.0);
        if (result >= 2.71 && result <= 2.72) begin
            $display("Test 4: $exp(1) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 4: $exp(1) = %f FAIL", result);
        end

        // Test $sin
        test_count++;
        result = $sin(0.0);
        if (result >= -0.01 && result <= 0.01) begin
            $display("Test 5: $sin(0) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 5: $sin(0) = %f FAIL", result);
        end

        // Test $cos
        test_count++;
        result = $cos(0.0);
        if (result >= 0.99 && result <= 1.01) begin
            $display("Test 6: $cos(0) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 6: $cos(0) = %f FAIL", result);
        end

        // Test $tan
        test_count++;
        result = $tan(0.0);
        if (result >= -0.01 && result <= 0.01) begin
            $display("Test 7: $tan(0) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 7: $tan(0) = %f FAIL", result);
        end

        // Test $asin
        test_count++;
        result = $asin(0.0);
        if (result >= -0.01 && result <= 0.01) begin
            $display("Test 8: $asin(0) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 8: $asin(0) = %f FAIL", result);
        end

        // Test $acos
        test_count++;
        result = $acos(1.0);
        if (result >= -0.01 && result <= 0.01) begin
            $display("Test 9: $acos(1) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 9: $acos(1) = %f FAIL", result);
        end

        // Test $atan
        test_count++;
        result = $atan(0.0);
        if (result >= -0.01 && result <= 0.01) begin
            $display("Test 10: $atan(0) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 10: $atan(0) = %f FAIL", result);
        end

        // Test $sinh
        test_count++;
        result = $sinh(0.0);
        if (result >= -0.01 && result <= 0.01) begin
            $display("Test 11: $sinh(0) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 11: $sinh(0) = %f FAIL", result);
        end

        // Test $cosh
        test_count++;
        result = $cosh(0.0);
        if (result >= 0.99 && result <= 1.01) begin
            $display("Test 12: $cosh(0) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 12: $cosh(0) = %f FAIL", result);
        end

        // Test $tanh
        test_count++;
        result = $tanh(0.0);
        if (result >= -0.01 && result <= 0.01) begin
            $display("Test 13: $tanh(0) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 13: $tanh(0) = %f FAIL", result);
        end

        // Test $ceil
        test_count++;
        result = $ceil(3.2);
        if (result >= 3.99 && result <= 4.01) begin
            $display("Test 14: $ceil(3.2) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 14: $ceil(3.2) = %f FAIL", result);
        end

        // Test $floor
        test_count++;
        result = $floor(3.8);
        if (result >= 2.99 && result <= 3.01) begin
            $display("Test 15: $floor(3.8) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 15: $floor(3.8) = %f FAIL", result);
        end

        // Test $pow
        test_count++;
        result = $pow(2.0, 3.0);
        if (result >= 7.99 && result <= 8.01) begin
            $display("Test 16: $pow(2,3) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 16: $pow(2,3) = %f FAIL", result);
        end

        // Test $atan2
        test_count++;
        result = $atan2(1.0, 1.0);
        if (result >= 0.78 && result <= 0.79) begin
            $display("Test 17: $atan2(1,1) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 17: $atan2(1,1) = %f FAIL", result);
        end

        // Test $hypot
        test_count++;
        result = $hypot(3.0, 4.0);
        if (result >= 4.99 && result <= 5.01) begin
            $display("Test 18: $hypot(3,4) = %f PASS", result);
            pass_count++;
        end else begin
            $display("Test 18: $hypot(3,4) = %f FAIL", result);
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
