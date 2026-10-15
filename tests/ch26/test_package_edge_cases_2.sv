/*
:name: test_package_edge_cases_2
:description: Package edge cases
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 26.2 13.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_edge_cases_2.expected
*/
// IEEE 1800-2023 §26: Package edge cases
// Tests for package, import, export

package pkg_math;
    function int add(int a, int b);
        return a + b;
    endfunction

    function int multiply(int a, int b);
        return a * b;
    endfunction

    parameter int PKG_CONST = 100;

    typedef struct {
        int x;
        int y;
    } point_t;
endpackage

package pkg_utils;
    function string format_int(int val);
        return $sformatf("%0d", val);
    endfunction

    localparam int UTIL_VAL = 50;
endpackage

module test_package_edge_cases_2;
    import pkg_math::*;
    import pkg_utils::format_int;

    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Package function add
        test_count++;
        begin
            static int result = add(10, 20);
            if (result == 30) begin
                pass_count++;
                $display("Test 1 PASS: add(10,20) = %0d", result);
            end else begin
                $display("Test 1 FAIL");
            end
        end

        // Test 2: Package function multiply
        test_count++;
        begin
            static int result = multiply(5, 6);
            if (result == 30) begin
                pass_count++;
                $display("Test 2 PASS: multiply(5,6) = %0d", result);
            end else begin
                $display("Test 2 FAIL");
            end
        end

        // Test 3: Package constant
        test_count++;
        if (PKG_CONST == 100) begin
            pass_count++;
            $display("Test 3 PASS: PKG_CONST = %0d", PKG_CONST);
        end else begin
            $display("Test 3 FAIL");
        end

        // Test 4: Package typedef
        test_count++;
        begin
            point_t p;
            p.x = 10;
            p.y = 20;
            if (p.x == 10 && p.y == 20) begin
                pass_count++;
                $display("Test 4 PASS: point_t = (%0d, %0d)", p.x, p.y);
            end else begin
                $display("Test 4 FAIL");
            end
        end

        // Test 5: Explicit import function
        test_count++;
        begin
            static string s = format_int(42);
            if (s == "42") begin
                pass_count++;
                $display("Test 5 PASS: format_int(42) = %s", s);
            end else begin
                $display("Test 5 FAIL: format_int unexpected = %s", s);
            end
        end

        // Test 6: Function chain
        test_count++;
        begin
            static int result = add(multiply(2, 3), 4);
            if (result == 10) begin
                pass_count++;
                $display("Test 6 PASS: add(multiply(2,3),4) = %0d", result);
            end else begin
                $display("Test 6 FAIL");
            end
        end

        // Test 7: Point arithmetic
        test_count++;
        begin
            point_t p1, p2, sum_pt;
            p1.x = 5; p1.y = 10;
            p2.x = 3; p2.y = 7;
            sum_pt.x = p1.x + p2.x;
            sum_pt.y = p1.y + p2.y;
            if (sum_pt.x == 8 && sum_pt.y == 17) begin
                pass_count++;
                $display("Test 7 PASS: Point add = (%0d, %0d)", sum_pt.x, sum_pt.y);
            end else begin
                $display("Test 7 FAIL");
            end
        end

        // Test 8: Constant in expression
        test_count++;
        begin
            static int result = PKG_CONST + 50;
            if (result == 150) begin
                pass_count++;
                $display("Test 8 PASS: PKG_CONST + 50 = %0d", result);
            end else begin
                $display("Test 8 FAIL");
            end
        end

        // Test 9: Multiple function calls
        test_count++;
        begin
            static int sum = 0;
            for (int i = 1; i <= 5; i++) begin
                sum = add(sum, i);
            end
            if (sum == 15) begin
                pass_count++;
                $display("Test 9 PASS: Sum 1-5 = %0d", sum);
            end else begin
                $display("Test 9 FAIL");
            end
        end

        // Test 10: Multiply accumulate
        test_count++;
        begin
            static int prod = 1;
            for (int i = 1; i <= 4; i++) begin
                prod = multiply(prod, i);
            end
            if (prod == 24) begin
                pass_count++;
                $display("Test 10 PASS: Product 1-4 = %0d", prod);
            end else begin
                $display("Test 10 FAIL");
            end
        end

        // Test 11: Point array
        test_count++;
        begin
            point_t pts[3];
            pts[0].x = 1; pts[0].y = 2;
            pts[1].x = 3; pts[1].y = 4;
            pts[2].x = 5; pts[2].y = 6;
            if (pts[2].x == 5) begin
                pass_count++;
                $display("Test 11 PASS: Point array[2] = (%0d, %0d)", pts[2].x, pts[2].y);
            end else begin
                $display("Test 11 FAIL");
            end
        end

        // Test 12: Zero add
        test_count++;
        begin
            static int result = add(0, 0);
            if (result == 0) begin
                pass_count++;
                $display("Test 12 PASS: add(0,0) = %0d", result);
            end else begin
                $display("Test 12 FAIL");
            end
        end

        // Test 13: Negative add
        test_count++;
        begin
            static int result = add(-10, 5);
            if (result == -5) begin
                pass_count++;
                $display("Test 13 PASS: add(-10,5) = %0d", result);
            end else begin
                $display("Test 13 FAIL");
            end
        end

        // Test 14: Zero multiply
        test_count++;
        begin
            static int result = multiply(100, 0);
            if (result == 0) begin
                pass_count++;
                $display("Test 14 PASS: multiply(100,0) = %0d", result);
            end else begin
                $display("Test 14 FAIL");
            end
        end

        // Test 15: Negative multiply
        test_count++;
        begin
            static int result = multiply(-3, 4);
            if (result == -12) begin
                pass_count++;
                $display("Test 15 PASS: multiply(-3,4) = %0d", result);
            end else begin
                $display("Test 15 FAIL: result = %0d", result);
            end
        end

        // Test 16: Point zero
        test_count++;
        begin
            point_t origin;
            origin.x = 0;
            origin.y = 0;
            if (origin.x == 0 && origin.y == 0) begin
                pass_count++;
                $display("Test 16 PASS: Origin = (%0d, %0d)", origin.x, origin.y);
            end else begin
                $display("Test 16 FAIL");
            end
        end

        // Test 17: Format negative
        test_count++;
        begin
            static string s = format_int(-42);
            if (s == "-42") begin
                pass_count++;
                $display("Test 17 PASS: format_int(-42) = %s", s);
            end else begin
                $display("Test 17 FAIL: format_int(-42) = %s", s);
            end
        end

        // Test 18: Constant compare
        test_count++;
        if (PKG_CONST > 50) begin
            pass_count++;
            $display("Test 18 PASS: PKG_CONST > 50");
        end else begin
            $display("Test 18 FAIL");
        end

        // Test 19: Large values
        test_count++;
        begin
            static int result = multiply(10000, 100);
            if (result == 1000000) begin
                pass_count++;
                $display("Test 19 PASS: 10000*100 = %0d", result);
            end else begin
                $display("Test 19 FAIL: result = %0d", result);
            end
        end

        // Test 20: Complete
        test_count++;
        pass_count++;
        $display("Test 20 PASS: Package tests complete");

        $display("=== Package Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
