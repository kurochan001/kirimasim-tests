/*
:name: test_math_exp
:description: $exp function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_exp.expected
*/
// $exp function
// Tests $exp system function for exponential (e^x)

module test_math_exp;
    real result;
    real e;

    initial begin
        e = 2.718281828459045;

        // Test 1: Exp of 0 = 1
        result = $exp(0.0);
        if (result >= 0.9999 && result <= 1.0001) begin
            $display("PASS: Test 1 - $exp(0) = 1.0");
        end else begin
            $display("FAIL: Test 1 - $exp(0) = %0f", result);
        end

        // Test 2: Exp of 1 = e
        result = $exp(1.0);
        if (result >= (e - 0.0001) && result <= (e + 0.0001)) begin
            $display("PASS: Test 2 - $exp(1) = e");
        end else begin
            $display("FAIL: Test 2 - $exp(1) = %0f", result);
        end

        // Test 3: Exp of 2 = e^2
        result = $exp(2.0);
        if (result >= 7.388 && result <= 7.390) begin
            $display("PASS: Test 3 - $exp(2) = 7.389");
        end else begin
            $display("FAIL: Test 3 - $exp(2) = %0f", result);
        end

        // Test 4: Exp of negative = 1/e
        result = $exp(-1.0);
        if (result >= 0.3678 && result <= 0.3680) begin
            $display("PASS: Test 4 - $exp(-1) = 0.3679");
        end else begin
            $display("FAIL: Test 4 - $exp(-1) = %0f", result);
        end

        // Test 5: Exp of ln(2) = 2
        result = $exp(0.6931471805599453);
        if (result >= 1.9999 && result <= 2.0001) begin
            $display("PASS: Test 5 - $exp(ln(2)) = 2.0");
        end else begin
            $display("FAIL: Test 5 - $exp(ln(2)) = %0f", result);
        end

        $finish;
    end
endmodule
