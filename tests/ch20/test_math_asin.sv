/*
:name: test_math_asin
:description: $asin function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_asin.expected
*/
// $asin function
// Tests $asin system function for arc sine calculation

module test_math_asin;
    real result;
    real pi;

    initial begin
        pi = 3.14159265358979323846;

        // Test 1: Asin of 0 = 0
        result = $asin(0.0);
        if (result >= -0.0001 && result <= 0.0001) begin
            $display("PASS: Test 1 - $asin(0) = 0");
        end else begin
            $display("FAIL: Test 1 - $asin(0) = %0f", result);
        end

        // Test 2: Asin of 1 = pi/2
        result = $asin(1.0);
        if (result >= (pi/2.0 - 0.0001) && result <= (pi/2.0 + 0.0001)) begin
            $display("PASS: Test 2 - $asin(1) = pi/2");
        end else begin
            $display("FAIL: Test 2 - $asin(1) = %0f", result);
        end

        // Test 3: Asin of -1 = -pi/2
        result = $asin(-1.0);
        if (result >= (-pi/2.0 - 0.0001) && result <= (-pi/2.0 + 0.0001)) begin
            $display("PASS: Test 3 - $asin(-1) = -pi/2");
        end else begin
            $display("FAIL: Test 3 - $asin(-1) = %0f", result);
        end

        // Test 4: Asin of 0.5 = pi/6
        result = $asin(0.5);
        if (result >= (pi/6.0 - 0.0001) && result <= (pi/6.0 + 0.0001)) begin
            $display("PASS: Test 4 - $asin(0.5) = pi/6");
        end else begin
            $display("FAIL: Test 4 - $asin(0.5) = %0f", result);
        end

        // Test 5: Asin of -0.5 = -pi/6
        result = $asin(-0.5);
        if (result >= (-pi/6.0 - 0.0001) && result <= (-pi/6.0 + 0.0001)) begin
            $display("PASS: Test 5 - $asin(-0.5) = -pi/6");
        end else begin
            $display("FAIL: Test 5 - $asin(-0.5) = %0f", result);
        end

        $finish;
    end
endmodule
