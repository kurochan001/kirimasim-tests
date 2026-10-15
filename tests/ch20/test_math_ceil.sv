/*
:name: test_math_ceil
:description: $ceil function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_ceil.expected
*/
// $ceil function
// Tests $ceil system function for ceiling operation

module test_math_ceil;
    real result;

    initial begin
        // Test 1: Ceil of positive fractional
        result = $ceil(3.2);
        if (result == 4.0) begin
            $display("PASS: Test 1 - $ceil(3.2) = 4.0");
        end else begin
            $display("FAIL: Test 1 - $ceil(3.2) = %0f", result);
        end

        // Test 2: Ceil of negative fractional
        result = $ceil(-3.2);
        if (result == -3.0) begin
            $display("PASS: Test 2 - $ceil(-3.2) = -3.0");
        end else begin
            $display("FAIL: Test 2 - $ceil(-3.2) = %0f", result);
        end

        // Test 3: Ceil of integer value
        result = $ceil(5.0);
        if (result == 5.0) begin
            $display("PASS: Test 3 - $ceil(5.0) = 5.0");
        end else begin
            $display("FAIL: Test 3 - $ceil(5.0) = %0f", result);
        end

        // Test 4: Ceil of small positive
        result = $ceil(0.001);
        if (result == 1.0) begin
            $display("PASS: Test 4 - $ceil(0.001) = 1.0");
        end else begin
            $display("FAIL: Test 4 - $ceil(0.001) = %0f", result);
        end

        // Test 5: Ceil of zero
        result = $ceil(0.0);
        if (result == 0.0) begin
            $display("PASS: Test 5 - $ceil(0.0) = 0.0");
        end else begin
            $display("FAIL: Test 5 - $ceil(0.0) = %0f", result);
        end

        $finish;
    end
endmodule
