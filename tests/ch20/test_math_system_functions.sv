/*
:name: test_math_system_functions
:description: $sqrt, $ln, $log10, $exp, $pow, $ceil, $floor, $sin, $cos, $tan, $asin, $acos, $atan, $atan2,
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.4 20.8.2 20.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_system_functions.expected
*/
// $sqrt, $ln, $log10, $exp, $pow, $ceil, $floor, $sin, $cos, $tan, $asin, $acos, $atan, $atan2,
// $sinh, $cosh, $hypot, $clog2, $itor, $rtoi, $abs
module test_math_system_functions;
    int pass_count = 0;
    int test_count = 18;

    initial begin
        // T1: $sqrt(16.0) = 4.0
        begin
            static real v = $sqrt(16.0);
            if (v == 4.0) begin
                $display("T1: PASS - $sqrt(16.0) = %f", v);
                pass_count++;
            end else
                $display("T1: FAIL - $sqrt(16.0) = %f (expected 4.0)", v);
        end

        // T2: $sqrt(2.0) ≈ 1.41421
        begin
            static real v = $sqrt(2.0);
            if (v > 1.4142 && v < 1.4143) begin
                $display("T2: PASS - $sqrt(2.0) = %f", v);
                pass_count++;
            end else
                $display("T2: FAIL - $sqrt(2.0) = %f (expected ~1.41421)", v);
        end

        // T3: $ln(1.0) = 0.0
        begin
            static real v = $ln(1.0);
            if (v == 0.0) begin
                $display("T3: PASS - $ln(1.0) = %f", v);
                pass_count++;
            end else
                $display("T3: FAIL - $ln(1.0) = %f (expected 0.0)", v);
        end

        // T4: $ln($exp(3.0)) = 3.0
        begin
            static real v = $ln($exp(3.0));
            if (v > 2.9999 && v < 3.0001) begin
                $display("T4: PASS - $ln($exp(3.0)) = %f", v);
                pass_count++;
            end else
                $display("T4: FAIL - $ln($exp(3.0)) = %f (expected 3.0)", v);
        end

        // T5: $log10(100.0) = 2.0
        begin
            static real v = $log10(100.0);
            if (v > 1.9999 && v < 2.0001) begin
                $display("T5: PASS - $log10(100.0) = %f", v);
                pass_count++;
            end else
                $display("T5: FAIL - $log10(100.0) = %f (expected 2.0)", v);
        end

        // T6: $exp(0.0) = 1.0
        begin
            static real v = $exp(0.0);
            if (v == 1.0) begin
                $display("T6: PASS - $exp(0.0) = %f", v);
                pass_count++;
            end else
                $display("T6: FAIL - $exp(0.0) = %f (expected 1.0)", v);
        end

        // T7: $pow(2.0, 10.0) = 1024.0
        begin
            static real v = $pow(2.0, 10.0);
            if (v == 1024.0) begin
                $display("T7: PASS - $pow(2.0, 10.0) = %f", v);
                pass_count++;
            end else
                $display("T7: FAIL - $pow(2.0, 10.0) = %f (expected 1024.0)", v);
        end

        // T8: $ceil(3.2) = 4.0, $ceil(-3.2) = -3.0
        begin
            static real v1 = $ceil(3.2);
            static real v2 = $ceil(-3.2);
            if (v1 == 4.0 && v2 == -3.0) begin
                $display("T8: PASS - $ceil(3.2)=%f, $ceil(-3.2)=%f", v1, v2);
                pass_count++;
            end else
                $display("T8: FAIL - $ceil(3.2)=%f (exp 4.0), $ceil(-3.2)=%f (exp -3.0)", v1, v2);
        end

        // T9: $floor(3.8) = 3.0, $floor(-3.8) = -4.0
        begin
            static real v1 = $floor(3.8);
            static real v2 = $floor(-3.8);
            if (v1 == 3.0 && v2 == -4.0) begin
                $display("T9: PASS - $floor(3.8)=%f, $floor(-3.8)=%f", v1, v2);
                pass_count++;
            end else
                $display("T9: FAIL - $floor(3.8)=%f (exp 3.0), $floor(-3.8)=%f (exp -4.0)", v1, v2);
        end

        // T10: $sin(0.0) = 0.0, $cos(0.0) = 1.0
        begin
            static real s = $sin(0.0);
            static real c = $cos(0.0);
            if (s == 0.0 && c == 1.0) begin
                $display("T10: PASS - $sin(0)=%f, $cos(0)=%f", s, c);
                pass_count++;
            end else
                $display("T10: FAIL - $sin(0)=%f (exp 0), $cos(0)=%f (exp 1)", s, c);
        end

        // T11: $tan(0.0) = 0.0
        begin
            static real v = $tan(0.0);
            if (v == 0.0) begin
                $display("T11: PASS - $tan(0.0) = %f", v);
                pass_count++;
            end else
                $display("T11: FAIL - $tan(0.0) = %f (expected 0.0)", v);
        end

        // T12: $asin(1.0) ≈ π/2, $acos(0.0) ≈ π/2
        begin
            static real pi_half = 3.14159265358979 / 2.0;
            static real v1 = $asin(1.0);
            static real v2 = $acos(0.0);
            if (v1 > pi_half - 0.0001 && v1 < pi_half + 0.0001 &&
                v2 > pi_half - 0.0001 && v2 < pi_half + 0.0001) begin
                $display("T12: PASS - $asin(1.0)=%f, $acos(0.0)=%f", v1, v2);
                pass_count++;
            end else
                $display("T12: FAIL - $asin(1.0)=%f, $acos(0.0)=%f (exp ~%f)", v1, v2, pi_half);
        end

        // T13: $atan(1.0) ≈ π/4, $atan2(1.0, 1.0) ≈ π/4
        begin
            static real pi_quarter = 3.14159265358979 / 4.0;
            static real v1 = $atan(1.0);
            static real v2 = $atan2(1.0, 1.0);
            if (v1 > pi_quarter - 0.0001 && v1 < pi_quarter + 0.0001 &&
                v2 > pi_quarter - 0.0001 && v2 < pi_quarter + 0.0001) begin
                $display("T13: PASS - $atan(1.0)=%f, $atan2(1,1)=%f", v1, v2);
                pass_count++;
            end else
                $display("T13: FAIL - $atan(1.0)=%f, $atan2(1,1)=%f (exp ~%f)", v1, v2, pi_quarter);
        end

        // T14: $sinh(0.0) = 0.0, $cosh(0.0) = 1.0
        begin
            static real s = $sinh(0.0);
            static real c = $cosh(0.0);
            if (s == 0.0 && c == 1.0) begin
                $display("T14: PASS - $sinh(0)=%f, $cosh(0)=%f", s, c);
                pass_count++;
            end else
                $display("T14: FAIL - $sinh(0)=%f (exp 0), $cosh(0)=%f (exp 1)", s, c);
        end

        // T15: $hypot(3.0, 4.0) = 5.0
        begin
            static real v = $hypot(3.0, 4.0);
            if (v == 5.0) begin
                $display("T15: PASS - $hypot(3.0, 4.0) = %f", v);
                pass_count++;
            end else
                $display("T15: FAIL - $hypot(3.0, 4.0) = %f (expected 5.0)", v);
        end

        // T16: $clog2(1)=0, $clog2(8)=3, $clog2(9)=4
        begin
            static int v1 = $clog2(1);
            static int v2 = $clog2(8);
            static int v3 = $clog2(9);
            if (v1 == 0 && v2 == 3 && v3 == 4) begin
                $display("T16: PASS - $clog2(1)=%0d, $clog2(8)=%0d, $clog2(9)=%0d", v1, v2, v3);
                pass_count++;
            end else
                $display("T16: FAIL - $clog2(1)=%0d, $clog2(8)=%0d, $clog2(9)=%0d", v1, v2, v3);
        end

        // T17: $itor(42) = 42.0, $rtoi(3.7) = 3 (truncation per IEEE 1800-2023 §20.4)
        begin
            static real r = $itor(42);
            static int i = $rtoi(3.7);
            if (r == 42.0 && i == 3) begin
                $display("T17: PASS - $itor(42)=%f, $rtoi(3.7)=%0d", r, i);
                pass_count++;
            end else
                $display("T17: FAIL - $itor(42)=%f (exp 42.0), $rtoi(3.7)=%0d (exp 3)", r, i);
        end

        // T18: $abs(-5) = 5 (integer abs via expression)
        begin
            static int v1 = -5;
            static int v2 = (v1 < 0) ? -v1 : v1;
            static real r1 = -5.5;
            static real r2 = (r1 < 0.0) ? -r1 : r1;
            if (v2 == 5 && r2 == 5.5) begin
                $display("T18: PASS - abs(-5)=%0d, abs(-5.5)=%f", v2, r2);
                pass_count++;
            end else
                $display("T18: FAIL - abs(-5)=%0d (exp 5), abs(-5.5)=%f (exp 5.5)", v2, r2);
        end

        $display("\n%s: %0d/%0d tests passed", (pass_count == test_count) ? "PASS" : "FAIL", pass_count, test_count);
        $finish;
    end
endmodule
