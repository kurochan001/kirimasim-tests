/*
:name: test_math_advanced
:description: Hyperbolic functions, ceil/floor, hypot, atan2, edge cases
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2 6.12 13.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_advanced.expected
*/
// Hyperbolic functions, ceil/floor, hypot, atan2, edge cases
module test_math_advanced;
    int pass_count = 0;
    int test_count = 16;

    // Tolerance check for real comparison
    function automatic bit approx(real a, real b, real tol = 0.01);
        real diff = a - b;
        if (diff < 0) diff = -diff;
        return diff < tol;
    endfunction

    initial begin
        // T1: $sinh(1.0) ≈ 1.1752
        begin
            static real v = $sinh(1.0);
            if (approx(v, 1.1752, 0.01)) begin
                $display("T1: PASS - $sinh(1.0) = %f", v);
                pass_count++;
            end else $display("T1: FAIL - $sinh(1.0) = %f expected ~1.1752", v);
        end

        // T2: $cosh(1.0) ≈ 1.5431
        begin
            static real v = $cosh(1.0);
            if (approx(v, 1.5431, 0.01)) begin
                $display("T2: PASS - $cosh(1.0) = %f", v);
                pass_count++;
            end else $display("T2: FAIL - $cosh(1.0) = %f expected ~1.5431", v);
        end

        // T3: $tanh(0.5) ≈ 0.4621
        begin
            static real v = $tanh(0.5);
            if (approx(v, 0.4621, 0.01)) begin
                $display("T3: PASS - $tanh(0.5) = %f", v);
                pass_count++;
            end else $display("T3: FAIL - $tanh(0.5) = %f expected ~0.4621", v);
        end

        // T4: $asinh(1.0) ≈ 0.8814
        begin
            static real v = $asinh(1.0);
            if (approx(v, 0.8814, 0.01)) begin
                $display("T4: PASS - $asinh(1.0) = %f", v);
                pass_count++;
            end else $display("T4: FAIL - $asinh(1.0) = %f expected ~0.8814", v);
        end

        // T5: $acosh(2.0) ≈ 1.3170
        begin
            static real v = $acosh(2.0);
            if (approx(v, 1.3170, 0.01)) begin
                $display("T5: PASS - $acosh(2.0) = %f", v);
                pass_count++;
            end else $display("T5: FAIL - $acosh(2.0) = %f expected ~1.3170", v);
        end

        // T6: $atanh(0.5) ≈ 0.5493
        begin
            static real v = $atanh(0.5);
            if (approx(v, 0.5493, 0.01)) begin
                $display("T6: PASS - $atanh(0.5) = %f", v);
                pass_count++;
            end else $display("T6: FAIL - $atanh(0.5) = %f expected ~0.5493", v);
        end

        // T7: $hypot(3.0, 4.0) = 5.0
        begin
            static real v = $hypot(3.0, 4.0);
            if (approx(v, 5.0, 0.001)) begin
                $display("T7: PASS - $hypot(3,4) = %f", v);
                pass_count++;
            end else $display("T7: FAIL - $hypot(3,4) = %f expected 5.0", v);
        end

        // T8: $ceil(2.3) = 3.0
        begin
            static real v = $ceil(2.3);
            if (approx(v, 3.0, 0.001)) begin
                $display("T8: PASS - $ceil(2.3) = %f", v);
                pass_count++;
            end else $display("T8: FAIL - $ceil(2.3) = %f expected 3.0", v);
        end

        // T9: $floor(2.7) = 2.0
        begin
            static real v = $floor(2.7);
            if (approx(v, 2.0, 0.001)) begin
                $display("T9: PASS - $floor(2.7) = %f", v);
                pass_count++;
            end else $display("T9: FAIL - $floor(2.7) = %f expected 2.0", v);
        end

        // T10: $exp(1.0) and $ln round-trip
        begin
            static real e = $exp(1.0);
            static real back;
            // Assigned here so the result does not depend on the order of static initializers.
            back = $ln(e);
            if (approx(back, 1.0, 0.001)) begin
                $display("T10: PASS - $ln($exp(1.0)) = %f", back);
                pass_count++;
            end else $display("T10: FAIL - $ln($exp(1.0)) = %f expected 1.0", back);
        end

        // T11: $pow(2.0, 10.0) = 1024.0
        begin
            static real v = $pow(2.0, 10.0);
            if (approx(v, 1024.0, 0.1)) begin
                $display("T11: PASS - $pow(2,10) = %f", v);
                pass_count++;
            end else $display("T11: FAIL - $pow(2,10) = %f expected 1024.0", v);
        end

        // T12: $sqrt(2.0) * $sqrt(2.0) ≈ 2.0
        begin
            static real s = $sqrt(2.0);
            static real v;
            // Assigned here so the result does not depend on the order of static initializers.
            v = s * s;
            if (approx(v, 2.0, 0.001)) begin
                $display("T12: PASS - sqrt(2)*sqrt(2) = %f", v);
                pass_count++;
            end else $display("T12: FAIL - sqrt(2)*sqrt(2) = %f expected ~2.0", v);
        end

        // T13: $log10(1000.0) = 3.0
        begin
            static real v = $log10(1000.0);
            if (approx(v, 3.0, 0.001)) begin
                $display("T13: PASS - $log10(1000) = %f", v);
                pass_count++;
            end else $display("T13: FAIL - $log10(1000) = %f expected 3.0", v);
        end

        // T14: $atan2(1.0, 1.0) ≈ π/4 ≈ 0.7854
        begin
            static real v = $atan2(1.0, 1.0);
            if (approx(v, 0.7854, 0.01)) begin
                $display("T14: PASS - $atan2(1,1) = %f", v);
                pass_count++;
            end else $display("T14: FAIL - $atan2(1,1) = %f expected ~0.7854", v);
        end

        // T15: $sqrt(-1.0) — NaN check
        begin
            static real v = $sqrt(-1.0);
            // NaN != NaN
            if (v != v) begin
                $display("T15: PASS - $sqrt(-1) is NaN");
                pass_count++;
            end else $display("T15: FAIL - $sqrt(-1) = %f expected NaN", v);
        end

        // T16: $ln(0.0) — -infinity check
        begin
            static real v = $ln(0.0);
            if (v < -1.0e30) begin
                $display("T16: PASS - $ln(0) is very negative");  // how -inf prints is not fixed
                pass_count++;
            end else $display("T16: FAIL - $ln(0) = %f expected -inf", v);
        end

        // Summary
        $display("\n%0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count)
            $display("PASS");
        else
            $display("FAIL");
    end
endmodule
