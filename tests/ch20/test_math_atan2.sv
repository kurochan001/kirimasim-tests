/*
:name: test_math_atan2
:description: $atan2 function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_atan2.expected
*/
// $atan2 function
// Tests $atan2 system function for two-argument arc tangent

module test_math_atan2;
    real result;
    real pi;

    initial begin
        pi = 3.14159265358979323846;

        // Test 1: Atan2(0, 1) = 0 (positive x-axis)
        result = $atan2(0.0, 1.0);
        if (result >= -0.0001 && result <= 0.0001) begin
            $display("PASS: Test 1 - $atan2(0, 1) = 0");
        end else begin
            $display("FAIL: Test 1 - $atan2(0, 1) = %0f", result);
        end

        // Test 2: Atan2(1, 0) = pi/2 (positive y-axis)
        result = $atan2(1.0, 0.0);
        if (result >= (pi/2.0 - 0.0001) && result <= (pi/2.0 + 0.0001)) begin
            $display("PASS: Test 2 - $atan2(1, 0) = pi/2");
        end else begin
            $display("FAIL: Test 2 - $atan2(1, 0) = %0f", result);
        end

        // Test 3: Atan2(1, 1) = pi/4 (45 degrees)
        result = $atan2(1.0, 1.0);
        if (result >= (pi/4.0 - 0.0001) && result <= (pi/4.0 + 0.0001)) begin
            $display("PASS: Test 3 - $atan2(1, 1) = pi/4");
        end else begin
            $display("FAIL: Test 3 - $atan2(1, 1) = %0f", result);
        end

        // Test 4: Atan2(-1, 0) = -pi/2 (negative y-axis)
        result = $atan2(-1.0, 0.0);
        if (result >= (-pi/2.0 - 0.0001) && result <= (-pi/2.0 + 0.0001)) begin
            $display("PASS: Test 4 - $atan2(-1, 0) = -pi/2");
        end else begin
            $display("FAIL: Test 4 - $atan2(-1, 0) = %0f", result);
        end

        // Test 5: Atan2(0, -1) = pi (negative x-axis)
        result = $atan2(0.0, -1.0);
        if (result >= (pi - 0.0001) && result <= (pi + 0.0001)) begin
            $display("PASS: Test 5 - $atan2(0, -1) = pi");
        end else begin
            $display("FAIL: Test 5 - $atan2(0, -1) = %0f", result);
        end

        $finish;
    end
endmodule
