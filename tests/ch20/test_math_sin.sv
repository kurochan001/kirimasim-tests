/*
:name: test_math_sin
:description: $sin function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_sin.expected
*/
// $sin function
// Tests $sin system function for sine calculation

module test_math_sin;
    real result;
    real pi;

    initial begin
        pi = 3.14159265358979323846;

        // Test 1: Sin of 0
        result = $sin(0.0);
        if (result >= -0.0001 && result <= 0.0001) begin
            $display("PASS: Test 1 - $sin(0) = 0");
        end else begin
            $display("FAIL: Test 1 - $sin(0) = %0f", result);
        end

        // Test 2: Sin of pi/2 (90 degrees) = 1
        result = $sin(pi / 2.0);
        if (result >= 0.9999 && result <= 1.0001) begin
            $display("PASS: Test 2 - $sin(pi/2) = 1.0");
        end else begin
            $display("FAIL: Test 2 - $sin(pi/2) = %0f", result);
        end

        // Test 3: Sin of pi (180 degrees) = 0
        result = $sin(pi);
        if (result >= -0.0001 && result <= 0.0001) begin
            $display("PASS: Test 3 - $sin(pi) = 0");
        end else begin
            $display("FAIL: Test 3 - $sin(pi) = %0f", result);
        end

        // Test 4: Sin of 3*pi/2 (270 degrees) = -1
        result = $sin(3.0 * pi / 2.0);
        if (result >= -1.0001 && result <= -0.9999) begin
            $display("PASS: Test 4 - $sin(3*pi/2) = -1.0");
        end else begin
            $display("FAIL: Test 4 - $sin(3*pi/2) = %0f", result);
        end

        // Test 5: Sin of negative angle
        result = $sin(-pi / 2.0);
        if (result >= -1.0001 && result <= -0.9999) begin
            $display("PASS: Test 5 - $sin(-pi/2) = -1.0");
        end else begin
            $display("FAIL: Test 5 - $sin(-pi/2) = %0f", result);
        end

        $finish;
    end
endmodule
