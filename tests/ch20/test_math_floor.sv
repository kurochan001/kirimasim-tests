/*
:name: test_math_floor
:description: $floor function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_floor.expected
*/
// $floor function
// Tests $floor system function for floor operation

module test_math_floor;
    real result;

    initial begin
        // Test 1: Floor of positive fractional
        result = $floor(3.7);
        if (result == 3.0) begin
            $display("PASS: Test 1 - $floor(3.7) = 3.0");
        end else begin
            $display("FAIL: Test 1 - $floor(3.7) = %0f", result);
        end

        // Test 2: Floor of negative fractional
        result = $floor(-3.2);
        if (result == -4.0) begin
            $display("PASS: Test 2 - $floor(-3.2) = -4.0");
        end else begin
            $display("FAIL: Test 2 - $floor(-3.2) = %0f", result);
        end

        // Test 3: Floor of integer value
        result = $floor(5.0);
        if (result == 5.0) begin
            $display("PASS: Test 3 - $floor(5.0) = 5.0");
        end else begin
            $display("FAIL: Test 3 - $floor(5.0) = %0f", result);
        end

        // Test 4: Floor of small positive
        result = $floor(0.999);
        if (result == 0.0) begin
            $display("PASS: Test 4 - $floor(0.999) = 0.0");
        end else begin
            $display("FAIL: Test 4 - $floor(0.999) = %0f", result);
        end

        // Test 5: Floor of zero
        result = $floor(0.0);
        if (result == 0.0) begin
            $display("PASS: Test 5 - $floor(0.0) = 0.0");
        end else begin
            $display("FAIL: Test 5 - $floor(0.0) = %0f", result);
        end

        $finish;
    end
endmodule
