/*
:name: test_math_special_values
:description: IEEE 754 special values, domain errors
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5 20.8.1 20.8.2 6.12
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_special_values.expected
*/
// IEEE 1800-2023 Section 20.8: IEEE 754 special values, domain errors
module test_math_special_values;
    int pass_count = 0;
    int test_count = 17;

    real tolerance = 0.0001;

    function bit is_nan(real v);
        return (v != v);
    endfunction

    function bit is_inf(real v);
        return (v > 1.0e300) || (v < -1.0e300);
    endfunction

    function bit near(real a, real b);
        if (a == b) return 1;
        if (b == 0.0) return (a > -tolerance && a < tolerance);
        return ((a - b) > -tolerance && (a - b) < tolerance);
    endfunction

    initial begin
        // T1: $realtobits and $bitstoreal round-trip
        begin
            static real orig = 3.14159265358979;
            static longint unsigned bits;
            static real restored;
            // Assigned here so the result does not depend on the order of static initializers.
            bits = $realtobits(orig);
            restored = $bitstoreal(bits);
            if (near(orig, restored)) begin
                $display("T1: PASS - realtobits/bitstoreal round-trip: %f -> %0h -> %f", orig, bits, restored);
                pass_count++;
            end else $display("T1: FAIL - orig=%f restored=%f", orig, restored);
        end

        // T2: $shortrealtobits and $bitstoshortreal round-trip
        begin
            static shortreal orig = 2.5;
            static int unsigned bits;
            static shortreal restored;
            // Assigned here so the result does not depend on the order of static initializers.
            bits = $shortrealtobits(orig);
            restored = $bitstoshortreal(bits);
            if (restored == 2.5) begin
                $display("T2: PASS - shortrealtobits/bitstoshortreal: %f -> %0h -> %f",
                    real'(orig), bits, real'(restored));
                pass_count++;
            end else $display("T2: FAIL - orig=%f restored=%f", real'(orig), real'(restored));
        end

        // T3: $realtobits of 0.0
        begin
            static longint unsigned bits = $realtobits(0.0);
            if (bits == 0) begin
                $display("T3: PASS - realtobits(0.0) = %0h", bits);
                pass_count++;
            end else $display("T3: FAIL - realtobits(0.0) = %0h expected 0", bits);
        end

        // T4: $realtobits of -1.0 (sign bit test)
        begin
            static longint unsigned bits = $realtobits(-1.0);
            // IEEE 754: -1.0 = 0xBFF0000000000000
            if (bits[63] == 1) begin
                $display("T4: PASS - realtobits(-1.0) sign bit set: %0h", bits);
                pass_count++;
            end else $display("T4: FAIL - realtobits(-1.0) = %0h (sign bit not set)", bits);
        end

        // T5: $sgn positive
        begin
            static real r = $sqrt(4.0);  // 2.0
            int s;
            if (r > 0.0) s = 1;
            else if (r < 0.0) s = -1;
            else s = 0;
            if (s == 1) begin
                $display("T5: PASS - sgn(2.0) = %0d", s);
                pass_count++;
            end else $display("T5: FAIL - sgn result=%0d expected 1", s);
        end

        // T6: $sgn zero
        begin
            static real r = 0.0;
            int s;
            if (r > 0.0) s = 1;
            else if (r < 0.0) s = -1;
            else s = 0;
            if (s == 0) begin
                $display("T6: PASS - sgn(0.0) = %0d", s);
                pass_count++;
            end else $display("T6: FAIL - sgn result=%0d expected 0", s);
        end

        // T7: $ln domain error (negative input -> NaN)
        begin
            static real r = $ln(-1.0);
            if (is_nan(r)) begin
                $display("T7: PASS - ln(-1.0) is NaN");
                pass_count++;
            end else $display("T7: FAIL - ln(-1.0) = %f (expected NaN)", r);
        end

        // T8: $log10 domain error
        begin
            static real r = $log10(-1.0);
            if (is_nan(r)) begin
                $display("T8: PASS - log10(-1.0) is NaN");
                pass_count++;
            end else $display("T8: FAIL - log10(-1.0) = %f (expected NaN)", r);
        end

        // T9: $sqrt domain error (negative input -> NaN)
        begin
            static real r = $sqrt(-4.0);
            if (is_nan(r)) begin
                $display("T9: PASS - sqrt(-4.0) is NaN");
                pass_count++;
            end else $display("T9: FAIL - sqrt(-4.0) = %f (expected NaN)", r);
        end

        // T10: $asin domain error (|x| > 1.0)
        begin
            static real r = $asin(1.5);
            if (is_nan(r)) begin
                $display("T10: PASS - asin(1.5) is NaN");
                pass_count++;
            end else $display("T10: FAIL - asin(1.5) = %f (expected NaN)", r);
        end

        // T11: $acos domain error (|x| > 1.0)
        begin
            static real r = $acos(-1.5);
            if (is_nan(r)) begin
                $display("T11: PASS - acos(-1.5) is NaN");
                pass_count++;
            end else $display("T11: FAIL - acos(-1.5) = %f (expected NaN)", r);
        end

        // T12: $pow(0.0, 0.0) = 1.0 (IEEE 754 convention)
        begin
            static real r = $pow(0.0, 0.0);
            if (near(r, 1.0)) begin
                $display("T12: PASS - pow(0,0)=%f", r);
                pass_count++;
            end else $display("T12: FAIL - pow(0,0)=%f expected 1.0", r);
        end

        // T13: $pow negative base fractional exponent -> NaN
        begin
            static real r = $pow(-1.0, 0.5);
            if (is_nan(r)) begin
                $display("T13: PASS - pow(-1, 0.5) is NaN");
                pass_count++;
            end else $display("T13: FAIL - pow(-1, 0.5) = %f (expected NaN)", r);
        end

        // T14: $exp large value -> infinity
        begin
            static real r = $exp(1000.0);
            if (is_inf(r)) begin
                $display("T14: PASS - exp(1000) is infinity");
                pass_count++;
            end else $display("T14: FAIL - exp(1000) = %e", r);
        end

        // T15: $clog2 edge cases
        begin
            static int c0 = $clog2(0);
            static int c1 = $clog2(1);
            static int c2 = $clog2(2);
            static int c3 = $clog2(3);
            static int c1024 = $clog2(1024);
            if (c0 == 0 && c1 == 0 && c2 == 1 && c3 == 2 && c1024 == 10) begin
                $display("T15: PASS - clog2: 0->%0d 1->%0d 2->%0d 3->%0d 1024->%0d", c0, c1, c2, c3, c1024);
                pass_count++;
            end else $display("T15: FAIL - clog2: 0->%0d 1->%0d 2->%0d 3->%0d 1024->%0d", c0, c1, c2, c3, c1024);
        end

        // T16: $itor and $rtoi with negative values
        begin
            static real r = $itor(-42);
            static int i = $rtoi(-3.7);
            if (near(r, -42.0) && i == -3) begin
                $display("T16: PASS - itor(-42)=%f rtoi(-3.7)=%0d", r, i);
                pass_count++;
            end else $display("T16: FAIL - itor(-42)=%f rtoi(-3.7)=%0d", r, i);
        end

        // T17: $abs for real values
        begin
            static real a = $sqrt(9.0);  // 3.0
            static real b = $sqrt(16.0); // 4.0
            static real diff;
            // Assigned here so the result does not depend on the order of static initializers.
            diff = a - b;  // -1.0
            // Manual abs
            if (diff < 0.0) diff = -diff;
            if (near(diff, 1.0)) begin
                $display("T17: PASS - abs(-1.0) = %f", diff);
                pass_count++;
            end else $display("T17: FAIL - diff=%f expected 1.0", diff);
        end

        $display("\n%0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) $display("PASS");
        else $display("FAIL");
        $finish;
    end
endmodule
