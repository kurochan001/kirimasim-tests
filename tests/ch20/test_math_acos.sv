/*
:name: test_math_acos
:description: $acos function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_acos.expected
*/
// $acos function
// Tests $acos system function for arc cosine calculation

module test_math_acos;
    real result;
    real pi;

    initial begin
        pi = 3.14159265358979323846;

        // Test 1: Acos of 1 = 0
        result = $acos(1.0);
        if (result >= -0.0001 && result <= 0.0001) begin
            $display("PASS: Test 1 - $acos(1) = 0");
        end else begin
            $display("FAIL: Test 1 - $acos(1) = %0f", result);
        end

        // Test 2: Acos of 0 = pi/2
        result = $acos(0.0);
        if (result >= (pi/2.0 - 0.0001) && result <= (pi/2.0 + 0.0001)) begin
            $display("PASS: Test 2 - $acos(0) = pi/2");
        end else begin
            $display("FAIL: Test 2 - $acos(0) = %0f", result);
        end

        // Test 3: Acos of -1 = pi
        result = $acos(-1.0);
        if (result >= (pi - 0.0001) && result <= (pi + 0.0001)) begin
            $display("PASS: Test 3 - $acos(-1) = pi");
        end else begin
            $display("FAIL: Test 3 - $acos(-1) = %0f", result);
        end

        // Test 4: Acos of 0.5 = pi/3
        result = $acos(0.5);
        if (result >= (pi/3.0 - 0.0001) && result <= (pi/3.0 + 0.0001)) begin
            $display("PASS: Test 4 - $acos(0.5) = pi/3");
        end else begin
            $display("FAIL: Test 4 - $acos(0.5) = %0f", result);
        end

        // Test 5: Acos of sqrt(2)/2 = pi/4
        result = $acos(0.7071067811865476);
        if (result >= (pi/4.0 - 0.0001) && result <= (pi/4.0 + 0.0001)) begin
            $display("PASS: Test 5 - $acos(sqrt(2)/2) = pi/4");
        end else begin
            $display("FAIL: Test 5 - $acos(sqrt(2)/2) = %0f", result);
        end

        $finish;
    end
endmodule
