/*
:name: test_math_cos
:description: $cos function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_cos.expected
*/
// $cos function
// Tests $cos system function for cosine calculation

module test_math_cos;
    real result;
    real pi;

    initial begin
        pi = 3.14159265358979323846;

        // Test 1: Cos of 0 = 1
        result = $cos(0.0);
        if (result >= 0.9999 && result <= 1.0001) begin
            $display("PASS: Test 1 - $cos(0) = 1.0");
        end else begin
            $display("FAIL: Test 1 - $cos(0) = %0f", result);
        end

        // Test 2: Cos of pi/2 (90 degrees) = 0
        result = $cos(pi / 2.0);
        if (result >= -0.0001 && result <= 0.0001) begin
            $display("PASS: Test 2 - $cos(pi/2) = 0");
        end else begin
            $display("FAIL: Test 2 - $cos(pi/2) = %0f", result);
        end

        // Test 3: Cos of pi (180 degrees) = -1
        result = $cos(pi);
        if (result >= -1.0001 && result <= -0.9999) begin
            $display("PASS: Test 3 - $cos(pi) = -1.0");
        end else begin
            $display("FAIL: Test 3 - $cos(pi) = %0f", result);
        end

        // Test 4: Cos of 2*pi (360 degrees) = 1
        result = $cos(2.0 * pi);
        if (result >= 0.9999 && result <= 1.0001) begin
            $display("PASS: Test 4 - $cos(2*pi) = 1.0");
        end else begin
            $display("FAIL: Test 4 - $cos(2*pi) = %0f", result);
        end

        // Test 5: Cos of negative angle (even function)
        result = $cos(-pi / 3.0);
        if (result >= 0.499 && result <= 0.501) begin
            $display("PASS: Test 5 - $cos(-pi/3) = 0.5");
        end else begin
            $display("FAIL: Test 5 - $cos(-pi/3) = %0f", result);
        end

        $finish;
    end
endmodule
