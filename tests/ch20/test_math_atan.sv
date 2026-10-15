/*
:name: test_math_atan
:description: $atan function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_atan.expected
*/
// $atan function
// Tests $atan system function for arc tangent calculation

module test_math_atan;
    real result;
    real pi;

    initial begin
        pi = 3.14159265358979323846;

        // Test 1: Atan of 0 = 0
        result = $atan(0.0);
        if (result >= -0.0001 && result <= 0.0001) begin
            $display("PASS: Test 1 - $atan(0) = 0");
        end else begin
            $display("FAIL: Test 1 - $atan(0) = %0f", result);
        end

        // Test 2: Atan of 1 = pi/4
        result = $atan(1.0);
        if (result >= (pi/4.0 - 0.0001) && result <= (pi/4.0 + 0.0001)) begin
            $display("PASS: Test 2 - $atan(1) = pi/4");
        end else begin
            $display("FAIL: Test 2 - $atan(1) = %0f", result);
        end

        // Test 3: Atan of -1 = -pi/4
        result = $atan(-1.0);
        if (result >= (-pi/4.0 - 0.0001) && result <= (-pi/4.0 + 0.0001)) begin
            $display("PASS: Test 3 - $atan(-1) = -pi/4");
        end else begin
            $display("FAIL: Test 3 - $atan(-1) = %0f", result);
        end

        // Test 4: Atan of large positive (approaches pi/2)
        result = $atan(1000.0);
        if (result >= (pi/2.0 - 0.01) && result <= (pi/2.0)) begin
            $display("PASS: Test 4 - $atan(1000) approaches pi/2");
        end else begin
            $display("FAIL: Test 4 - $atan(1000) = %0f", result);
        end

        // Test 5: Atan of sqrt(3) = pi/3
        result = $atan(1.7320508075688772);
        if (result >= (pi/3.0 - 0.0001) && result <= (pi/3.0 + 0.0001)) begin
            $display("PASS: Test 5 - $atan(sqrt(3)) = pi/3");
        end else begin
            $display("FAIL: Test 5 - $atan(sqrt(3)) = %0f", result);
        end

        $finish;
    end
endmodule
