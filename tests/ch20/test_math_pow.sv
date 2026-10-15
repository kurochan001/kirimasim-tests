/*
:name: test_math_pow
:description: $pow function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_pow.expected
*/
// $pow function
// Tests $pow system function for power calculation (x^y)

module test_math_pow;
    real result;

    initial begin
        // Test 1: 2^3 = 8
        result = $pow(2.0, 3.0);
        if (result >= 7.9999 && result <= 8.0001) begin
            $display("PASS: Test 1 - $pow(2, 3) = 8.0");
        end else begin
            $display("FAIL: Test 1 - $pow(2, 3) = %0f", result);
        end

        // Test 2: 10^2 = 100
        result = $pow(10.0, 2.0);
        if (result >= 99.999 && result <= 100.001) begin
            $display("PASS: Test 2 - $pow(10, 2) = 100.0");
        end else begin
            $display("FAIL: Test 2 - $pow(10, 2) = %0f", result);
        end

        // Test 3: x^0 = 1
        result = $pow(5.0, 0.0);
        if (result >= 0.9999 && result <= 1.0001) begin
            $display("PASS: Test 3 - $pow(5, 0) = 1.0");
        end else begin
            $display("FAIL: Test 3 - $pow(5, 0) = %0f", result);
        end

        // Test 4: x^1 = x
        result = $pow(7.5, 1.0);
        if (result >= 7.499 && result <= 7.501) begin
            $display("PASS: Test 4 - $pow(7.5, 1) = 7.5");
        end else begin
            $display("FAIL: Test 4 - $pow(7.5, 1) = %0f", result);
        end

        // Test 5: Fractional exponent (square root)
        result = $pow(16.0, 0.5);
        if (result >= 3.9999 && result <= 4.0001) begin
            $display("PASS: Test 5 - $pow(16, 0.5) = 4.0");
        end else begin
            $display("FAIL: Test 5 - $pow(16, 0.5) = %0f", result);
        end

        $finish;
    end
endmodule
