/*
:name: test_math_tan
:description: $tan function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_tan.expected
*/
// $tan function
// Tests $tan system function for tangent calculation

module test_math_tan;
    real result;
    real pi;

    initial begin
        pi = 3.14159265358979323846;

        // Test 1: Tan of 0 = 0
        result = $tan(0.0);
        if (result >= -0.0001 && result <= 0.0001) begin
            $display("PASS: Test 1 - $tan(0) = 0");
        end else begin
            $display("FAIL: Test 1 - $tan(0) = %0f", result);
        end

        // Test 2: Tan of pi/4 (45 degrees) = 1
        result = $tan(pi / 4.0);
        if (result >= 0.9999 && result <= 1.0001) begin
            $display("PASS: Test 2 - $tan(pi/4) = 1.0");
        end else begin
            $display("FAIL: Test 2 - $tan(pi/4) = %0f", result);
        end

        // Test 3: Tan of pi (180 degrees) = 0
        result = $tan(pi);
        if (result >= -0.0001 && result <= 0.0001) begin
            $display("PASS: Test 3 - $tan(pi) = 0");
        end else begin
            $display("FAIL: Test 3 - $tan(pi) = %0f", result);
        end

        // Test 4: Tan of negative angle (odd function)
        result = $tan(-pi / 4.0);
        if (result >= -1.0001 && result <= -0.9999) begin
            $display("PASS: Test 4 - $tan(-pi/4) = -1.0");
        end else begin
            $display("FAIL: Test 4 - $tan(-pi/4) = %0f", result);
        end

        // Test 5: Tan of pi/6 (30 degrees) = 1/sqrt(3)
        result = $tan(pi / 6.0);
        if (result >= 0.577 && result <= 0.578) begin
            $display("PASS: Test 5 - $tan(pi/6) = 0.577");
        end else begin
            $display("FAIL: Test 5 - $tan(pi/6) = %0f", result);
        end

        $finish;
    end
endmodule
