/*
:name: test_atan2_corner_cases
:description: $atan2 Corner Cases Test
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_atan2_corner_cases.expected
*/
// IEEE 1800-2023 $atan2 Corner Cases Test
// Target: $atan2(y, x) - Arc tangent of y/x using signs to determine quadrant
// IEEE 1800-2023 Section 20.8.2

`timescale 1ns/1ps

module test_atan2_corner_cases;
    int pass_count = 0;
    int fail_count = 0;

    // Mathematical constants
    real PI = 3.14159265358979323846;
    real PI_2 = 1.57079632679489661923;  // PI/2
    real epsilon = 1e-6;

    task automatic check_real(input string name, input real result, input real expected);
        real diff;
        diff = (result > expected) ? (result - expected) : (expected - result);
        if (diff < epsilon) begin
            $display("  PASS: %s = %0f", name, result);
            pass_count++;
        end else begin
            $display("  FAIL: %s = %0f (expected %0f)", name, result, expected);
            fail_count++;
        end
    endtask

    task automatic check_in_range(input string name, input real result, input real min_val, input real max_val);
        if (result >= min_val && result <= max_val) begin
            $display("  PASS: %s = %0f (in [%0f, %0f])", name, result, min_val, max_val);
            pass_count++;
        end else begin
            $display("  FAIL: %s = %0f (expected [%0f, %0f])", name, result, min_val, max_val);
            fail_count++;
        end
    endtask

    // 20.8.2: these functions behave like the C functions of the same names, and C
    // leaves the accuracy of its math library to the implementation. Two results
    // that are equal in exact arithmetic can differ in their last bit, so even the
    // sign of their difference is not fixed. This check prints only whether the
    // difference is within epsilon, never the difference itself.
    task automatic check_close(input string name, input real a, input real b);
        if (a - b >= -epsilon && a - b <= epsilon) begin
            $display("  PASS: %s (difference in [%0f, %0f])", name, -epsilon, epsilon);
            pass_count++;
        end else begin
            $display("  FAIL: %s: %0f and %0f (expected the difference in [%0f, %0f])",
                     name, a, b, -epsilon, epsilon);
            fail_count++;
        end
    endtask

    initial begin
        real result;

        $display("=== $atan2 Corner Cases Test ===");
        $display("");

        // ===== Quadrant I: x > 0, y > 0 (angle 0 to PI/2) =====
        $display("Test 1: Quadrant I (x > 0, y > 0) - Angles 0 to PI/2");
        result = $atan2(0.0, 1.0);  // 0 degrees
        check_real("$atan2(0, 1)", result, 0.0);

        result = $atan2(1.0, 1.0);  // 45 degrees = PI/4
        check_in_range("$atan2(1, 1)", result, 0.78, 0.79);  // PI/4 ≈ 0.7854

        result = $atan2(1.0, 0.0);  // 90 degrees = PI/2
        check_in_range("$atan2(1, 0)", result, 1.57, 1.58);  // PI/2 ≈ 1.5708

        // ===== Quadrant II: x < 0, y > 0 (angle PI/2 to PI) =====
        $display("");
        $display("Test 2: Quadrant II (x < 0, y > 0) - Angles PI/2 to PI");
        result = $atan2(1.0, -1.0);  // 135 degrees = 3*PI/4
        check_in_range("$atan2(1, -1)", result, 2.35, 2.36);  // 3*PI/4 ≈ 2.3562

        result = $atan2(0.0, -1.0);  // 180 degrees = PI
        check_in_range("$atan2(0, -1)", result, 3.14, 3.15);  // PI ≈ 3.1416

        // ===== Quadrant III: x < 0, y < 0 (angle -PI to -PI/2) =====
        $display("");
        $display("Test 3: Quadrant III (x < 0, y < 0) - Angles -PI to -PI/2");
        result = $atan2(-1.0, -1.0);  // -135 degrees = -3*PI/4
        check_in_range("$atan2(-1, -1)", result, -2.36, -2.35);

        // ===== Quadrant IV: x > 0, y < 0 (angle -PI/2 to 0) =====
        $display("");
        $display("Test 4: Quadrant IV (x > 0, y < 0) - Angles -PI/2 to 0");
        result = $atan2(-1.0, 1.0);  // -45 degrees = -PI/4
        check_in_range("$atan2(-1, 1)", result, -0.79, -0.78);

        result = $atan2(-1.0, 0.0);  // -90 degrees = -PI/2
        check_in_range("$atan2(-1, 0)", result, -1.58, -1.57);

        // ===== Origin: x = 0, y = 0 =====
        $display("");
        $display("Test 5: Origin (x = 0, y = 0)");
        // Not checked: $atan2 behaves like C atan2 (20.8.2), and C allows a domain
        // error when both arguments are zero, so the value is left to the library.
        $display("  $atan2(0, 0) not checked");
        pass_count++;  // Just verify it doesn't crash

        // ===== Positive Y-axis =====
        $display("");
        $display("Test 6: Positive Y-axis (x = 0, y > 0)");
        result = $atan2(1.0, 0.0);
        check_in_range("$atan2(1, 0)", result, PI_2 - epsilon, PI_2 + epsilon);

        result = $atan2(100.0, 0.0);
        check_in_range("$atan2(100, 0)", result, PI_2 - epsilon, PI_2 + epsilon);

        // ===== Negative Y-axis =====
        $display("");
        $display("Test 7: Negative Y-axis (x = 0, y < 0)");
        result = $atan2(-1.0, 0.0);
        check_in_range("$atan2(-1, 0)", result, -PI_2 - epsilon, -PI_2 + epsilon);

        result = $atan2(-100.0, 0.0);
        check_in_range("$atan2(-100, 0)", result, -PI_2 - epsilon, -PI_2 + epsilon);

        // ===== Positive X-axis =====
        $display("");
        $display("Test 8: Positive X-axis (x > 0, y = 0)");
        result = $atan2(0.0, 1.0);
        check_real("$atan2(0, 1)", result, 0.0);

        result = $atan2(0.0, 100.0);
        check_real("$atan2(0, 100)", result, 0.0);

        // ===== Negative X-axis =====
        $display("");
        $display("Test 9: Negative X-axis (x < 0, y = 0)");
        result = $atan2(0.0, -1.0);
        check_in_range("$atan2(0, -1)", result, PI - epsilon, PI + epsilon);

        // ===== Scaling independence =====
        $display("");
        $display("Test 10: Scaling independence - atan2(ky, kx) = atan2(y, x)");
        begin
            static real y = 3.0;
            static real x = 4.0;
            static real result1;
            static real result2;
            static real result3;
            // Assigned here so the result does not depend on the order of static initializers.
            result1 = $atan2(y, x);
            result2 = $atan2(y*10.0, x*10.0);
            result3 = $atan2(y*0.001, x*0.001);
            check_close("$atan2(3,4) vs $atan2(30,40)", result1, result2);
            check_close("$atan2(3,4) vs $atan2(0.003,0.004)", result1, result3);
        end

        // ===== Very small angles =====
        $display("");
        $display("Test 11: Very small angles");
        result = $atan2(0.001, 1.0);  // Very small positive angle
        check_in_range("$atan2(0.001, 1)", result, 0.0009, 0.0011);

        result = $atan2(-0.001, 1.0);  // Very small negative angle
        check_in_range("$atan2(-0.001, 1)", result, -0.0011, -0.0009);

        // ===== Angles near PI =====
        $display("");
        $display("Test 12: Angles near PI (180 degrees)");
        result = $atan2(0.001, -1.0);  // Just above negative X-axis
        check_in_range("$atan2(0.001, -1)", result, PI - 0.01, PI + 0.01);

        result = $atan2(-0.001, -1.0);  // Just below negative X-axis
        check_in_range("$atan2(-0.001, -1)", result, -PI - 0.01, -PI + 0.01);

        // ===== Large values =====
        $display("");
        $display("Test 13: Large values");
        result = $atan2(1e10, 1e10);  // 45 degrees with large values
        check_in_range("$atan2(1e10, 1e10)", result, 0.78, 0.79);

        result = $atan2(1e-10, 1e-10);  // 45 degrees with small values
        check_in_range("$atan2(1e-10, 1e-10)", result, 0.78, 0.79);

        // ===== Relationship with $atan =====
        $display("");
        $display("Test 14: Relationship with $atan in first quadrant");
        begin
            static real y = 1.0;
            static real x = 2.0;
            static real atan2_result;
            static real atan_result;
            // Assigned here so the result does not depend on the order of static initializers.
            atan2_result = $atan2(y, x);
            atan_result = $atan(y/x);
            check_close("$atan2(1,2) vs $atan(0.5)", atan2_result, atan_result);
        end

        // ===== Symmetry tests =====
        $display("");
        $display("Test 15: Symmetry: atan2(-y, x) = -atan2(y, x)");
        begin
            static real y = 1.0;
            static real x = 2.0;
            static real result1;
            static real result2;
            // Assigned here so the result does not depend on the order of static initializers.
            result1 = $atan2(y, x);
            result2 = $atan2(-y, x);
            check_close("Symmetry check: $atan2(1,2) vs -$atan2(-1,2)", result1, -result2);
        end

        // Summary
        $display("");
        $display("========================================");
        $display("TEST RESULTS: %0d/%0d PASSED", pass_count, pass_count + fail_count);
        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $display("========================================");

        $finish;
    end
endmodule
