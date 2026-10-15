/*
:name: test_math_log10
:description: $log10 function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_log10.expected
*/
// $log10 function
// Tests $log10 system function for base-10 logarithm

module test_math_log10;
    real result;

    initial begin
        // Test 1: Log10 of 1 = 0
        result = $log10(1.0);
        if (result >= -0.0001 && result <= 0.0001) begin
            $display("PASS: Test 1 - $log10(1) = 0");
        end else begin
            $display("FAIL: Test 1 - $log10(1) = %0f", result);
        end

        // Test 2: Log10 of 10 = 1
        result = $log10(10.0);
        if (result >= 0.9999 && result <= 1.0001) begin
            $display("PASS: Test 2 - $log10(10) = 1.0");
        end else begin
            $display("FAIL: Test 2 - $log10(10) = %0f", result);
        end

        // Test 3: Log10 of 100 = 2
        result = $log10(100.0);
        if (result >= 1.9999 && result <= 2.0001) begin
            $display("PASS: Test 3 - $log10(100) = 2.0");
        end else begin
            $display("FAIL: Test 3 - $log10(100) = %0f", result);
        end

        // Test 4: Log10 of 1000 = 3
        result = $log10(1000.0);
        if (result >= 2.9999 && result <= 3.0001) begin
            $display("PASS: Test 4 - $log10(1000) = 3.0");
        end else begin
            $display("FAIL: Test 4 - $log10(1000) = %0f", result);
        end

        // Test 5: Log10 of 0.1 = -1
        result = $log10(0.1);
        if (result >= -1.0001 && result <= -0.9999) begin
            $display("PASS: Test 5 - $log10(0.1) = -1.0");
        end else begin
            $display("FAIL: Test 5 - $log10(0.1) = %0f", result);
        end

        $finish;
    end
endmodule
