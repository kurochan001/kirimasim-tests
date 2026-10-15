/*
:name: test_math_log
:description: $ln function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_log.expected
*/
// $ln function
// Tests $ln system function for natural logarithm

module test_math_log;
    real result;
    real e;

    initial begin
        e = 2.718281828459045;

        // Test 1: Ln of 1 = 0
        result = $ln(1.0);
        if (result >= -0.0001 && result <= 0.0001) begin
            $display("PASS: Test 1 - $ln(1) = 0");
        end else begin
            $display("FAIL: Test 1 - $ln(1) = %0f", result);
        end

        // Test 2: Ln of e = 1
        result = $ln(e);
        if (result >= 0.9999 && result <= 1.0001) begin
            $display("PASS: Test 2 - $ln(e) = 1.0");
        end else begin
            $display("FAIL: Test 2 - $ln(e) = %0f", result);
        end

        // Test 3: Ln of e^2 = 2
        result = $ln(e * e);
        if (result >= 1.9999 && result <= 2.0001) begin
            $display("PASS: Test 3 - $ln(e^2) = 2.0");
        end else begin
            $display("FAIL: Test 3 - $ln(e^2) = %0f", result);
        end

        // Test 4: Ln of 10
        result = $ln(10.0);
        if (result >= 2.302 && result <= 2.304) begin
            $display("PASS: Test 4 - $ln(10) = 2.303");
        end else begin
            $display("FAIL: Test 4 - $ln(10) = %0f", result);
        end

        // Test 5: Ln of 0.5 (negative result)
        result = $ln(0.5);
        if (result >= -0.6932 && result <= -0.6930) begin
            $display("PASS: Test 5 - $ln(0.5) = -0.693");
        end else begin
            $display("FAIL: Test 5 - $ln(0.5) = %0f", result);
        end

        $finish;
    end
endmodule
