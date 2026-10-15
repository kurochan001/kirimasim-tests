/*
:name: test_math_hyperbolic_special_values
:description: Hyperbolic and other real math functions, including arguments outside their domains (IEEE 1800-2023 Section 20.8.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_hyperbolic_special_values.expected
*/
// Hyperbolic and other real math functions, including results outside their
// domains (IEEE 1800-2023 Section 20.8.2). NaN and infinity are checked but not
// printed: how %f prints them is up to the C library.
module test_math_hyperbolic_special_values;
    int pass_count = 0;
    int test_count = 17;

    real tolerance;

    initial begin
        tolerance = 0.0001;

        // T1: $sinh basic values
        begin
            static real s0 = $sinh(0.0);
            static real s1 = $sinh(1.0);
            static real sn1 = $sinh(-1.0);
            // sinh(0)=0, sinh(1)≈1.1752, sinh(-1)≈-1.1752
            if (s0 < tolerance && s0 > -tolerance &&
                s1 > 1.17 && s1 < 1.18 &&
                sn1 > -1.18 && sn1 < -1.17) begin
                $display("T1: PASS - sinh: %f %f %f", s0, s1, sn1);
                pass_count++;
            end else $display("T1: FAIL - sinh: %f %f %f", s0, s1, sn1);
        end

        // T2: $cosh basic values
        begin
            static real c0 = $cosh(0.0);
            static real c1 = $cosh(1.0);
            // cosh(0)=1, cosh(1)≈1.5431
            if (c0 > 0.999 && c0 < 1.001 &&
                c1 > 1.54 && c1 < 1.55) begin
                $display("T2: PASS - cosh: %f %f", c0, c1);
                pass_count++;
            end else $display("T2: FAIL - cosh: %f %f", c0, c1);
        end

        // T3: $tanh basic values
        begin
            static real t0 = $tanh(0.0);
            static real t_large = $tanh(100.0);
            static real t_neg = $tanh(-100.0);
            // tanh(0)=0, tanh(large)→1, tanh(-large)→-1
            if (t0 < tolerance && t0 > -tolerance &&
                t_large > 0.999 && t_large <= 1.0 &&
                t_neg < -0.999 && t_neg >= -1.0) begin
                $display("T3: PASS - tanh: %f %f %f", t0, t_large, t_neg);
                pass_count++;
            end else $display("T3: FAIL - tanh: %f %f %f", t0, t_large, t_neg);
        end

        // T4: $asinh basic values
        begin
            static real as0 = $asinh(0.0);
            static real as1 = $asinh(1.0);
            // asinh(0)=0, asinh(1)≈0.8814
            if (as0 < tolerance && as0 > -tolerance &&
                as1 > 0.88 && as1 < 0.89) begin
                $display("T4: PASS - asinh: %f %f", as0, as1);
                pass_count++;
            end else $display("T4: FAIL - asinh: %f %f", as0, as1);
        end

        // T5: $acosh basic values
        begin
            static real ac1 = $acosh(1.0);
            static real ac2 = $acosh(2.0);
            // acosh(1)=0, acosh(2)≈1.3170
            if (ac1 < tolerance && ac1 > -tolerance &&
                ac2 > 1.31 && ac2 < 1.32) begin
                $display("T5: PASS - acosh: %f %f", ac1, ac2);
                pass_count++;
            end else $display("T5: FAIL - acosh: %f %f", ac1, ac2);
        end

        // T6: $atanh basic values
        begin
            static real at0 = $atanh(0.0);
            static real at05 = $atanh(0.5);
            // atanh(0)=0, atanh(0.5)≈0.5493
            if (at0 < tolerance && at0 > -tolerance &&
                at05 > 0.54 && at05 < 0.56) begin
                $display("T6: PASS - atanh: %f %f", at0, at05);
                pass_count++;
            end else $display("T6: FAIL - atanh: %f %f", at0, at05);
        end

        // T7: $acosh domain error — acosh(0.5) is NaN (domain: x >= 1)
        begin
            static real result = $acosh(0.5);
            // IEEE: acosh(x<1) = NaN
            if (result != result) begin // NaN check: NaN != NaN
                $display("T7: PASS - acosh(0.5) NaN");
                pass_count++;
            end else begin
                $display("T7: FAIL - acosh(0.5) expected NaN got: %f", result);
            end
        end

        // T8: $atanh(1.0) → Inf
        begin
            static real result = $atanh(1.0);
            // IEEE: atanh(1) = +Inf
            if (result > 1.0e10 || result != result) begin
                $display("T8: PASS - atanh(1.0) large/inf");
                pass_count++;
            end else begin
                $display("T8: FAIL - atanh(1.0) expected large got: %f", result);
            end
        end

        // T9: $atanh(2.0) → NaN (domain: |x| < 1)
        begin
            static real result = $atanh(2.0);
            if (result != result) begin
                $display("T9: PASS - atanh(2.0) NaN");
                pass_count++;
            end else begin
                $display("T9: FAIL - atanh(2.0) expected NaN got: %f", result);
            end
        end

        // T10: $ln(-1) → NaN
        begin
            static real result = $ln(-1.0);
            if (result != result) begin
                $display("T10: PASS - ln(-1) NaN");
                pass_count++;
            end else begin
                $display("T10: FAIL - ln(-1) expected NaN got: %f", result);
            end
        end

        // T11: sinh(asinh(x)) round-trip
        begin
            static real x = 2.5;
            static real trip;
            static real diff;
            // Assigned here so the result does not depend on the order of static initializers.
            trip = $sinh($asinh(x));
            diff = trip - x;
            if (diff < 0) diff = -diff;
            if (diff < 0.001) begin
                $display("T11: PASS - sinh(asinh(2.5))=%f diff=%f", trip, diff);
                pass_count++;
            end else $display("T11: FAIL - trip=%f diff=%f", trip, diff);
        end

        // T12: cosh(acosh(x)) round-trip
        begin
            static real x = 3.0;
            static real trip;
            static real diff;
            // Assigned here so the result does not depend on the order of static initializers.
            trip = $cosh($acosh(x));
            diff = trip - x;
            if (diff < 0) diff = -diff;
            if (diff < 0.001) begin
                $display("T12: PASS - cosh(acosh(3.0))=%f diff=%f", trip, diff);
                pass_count++;
            end else $display("T12: FAIL - trip=%f diff=%f", trip, diff);
        end

        // T13: tanh(atanh(x)) round-trip
        begin
            static real x = 0.75;
            static real trip;
            static real diff;
            // Assigned here so the result does not depend on the order of static initializers.
            trip = $tanh($atanh(x));
            diff = trip - x;
            if (diff < 0) diff = -diff;
            if (diff < 0.001) begin
                $display("T13: PASS - tanh(atanh(0.75))=%f diff=%f", trip, diff);
                pass_count++;
            end else $display("T13: FAIL - trip=%f diff=%f", trip, diff);
        end

        // T14: log10(10^x) round-trip
        begin
            static real x = 3.0;
            static real trip;
            static real diff;
            // Assigned here so the result does not depend on the order of static initializers.
            trip = $log10($pow(10.0, x));
            diff = trip - x;
            if (diff < 0) diff = -diff;
            if (diff < 0.001) begin
                $display("T14: PASS - log10(10^3)=%f diff=%f", trip, diff);
                pass_count++;
            end else $display("T14: FAIL - trip=%f diff=%f", trip, diff);
        end

        // T15: $sinh large → overflow/Inf
        begin
            static real result = $sinh(1000.0);
            // Should be very large or Inf
            if (result > 1.0e10 || result != result) begin
                $display("T15: PASS - sinh(1000) overflow");
                pass_count++;
            end else begin
                $display("T15: FAIL - sinh(1000) expected overflow: %f", result);
            end
        end

        // T16: $tanh large → ±1.0
        begin
            static real tp = $tanh(50.0);
            static real tn = $tanh(-50.0);
            if (tp > 0.9999 && tp <= 1.0001 &&
                tn < -0.9999 && tn >= -1.0001) begin
                $display("T16: PASS - tanh saturation: %f %f", tp, tn);
                pass_count++;
            end else $display("T16: FAIL - tp=%f tn=%f", tp, tn);
        end

        // T17: $exp large → Inf
        begin
            static real result = $exp(1000.0);
            if (result > 1.0e10 || result != result) begin
                $display("T17: PASS - exp(1000) overflow");
                pass_count++;
            end else begin
                $display("T17: FAIL - exp(1000): %f", result);
            end
        end

        $display("\n%0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) $display("PASS");
        else $display("FAIL");
        $finish;
    end
endmodule
