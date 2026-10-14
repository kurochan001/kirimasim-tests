/*
:name: test_package_edge_cases
:description: Package edge cases
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 26.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_edge_cases.expected
*/
// IEEE 1800-2023 §26: Package edge cases
// Tests for packages

package my_pkg;
    parameter WIDTH = 8;
    typedef logic [WIDTH-1:0] data_t;
    
    function automatic int add(int a, int b);
        return a + b;
    endfunction
    
    localparam MAX_VAL = 255;
endpackage

module test_package_edge_cases;
    import my_pkg::*;
    
    int pass_count = 0;
    int test_count = 0;

    data_t d1, d2;

    initial begin
        // Test 1: Package param
        test_count++;
        if (WIDTH == 8) begin
            pass_count++;
            $display("Test 1 PASS: WIDTH = %0d", WIDTH);
        end else begin
            $display("Test 1 FAIL: Param unexpected = %0d", WIDTH);
        end

        // Test 2: Package typedef
        test_count++;
        d1 = 8'hAB;
        if (d1 == 8'hAB) begin
            pass_count++;
            $display("Test 2 PASS: data_t = %h", d1);
        end else begin
            $display("Test 2 FAIL: Typedef unexpected = %h", d1);
        end

        // Test 3: Package function
        test_count++;
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = add(10, 20);
            if (result == 30) begin
                pass_count++;
                $display("Test 3 PASS: add(10,20) = %0d", result);
            end else begin
                $display("Test 3 FAIL: Func unexpected = %0d", result);
            end
        end

        // Test 4: Package localparam
        test_count++;
        if (MAX_VAL == 255) begin
            pass_count++;
            $display("Test 4 PASS: MAX_VAL = %0d", MAX_VAL);
        end else begin
            $display("Test 4 FAIL: Local unexpected = %0d", MAX_VAL);
        end

        // Test 5: Multiple uses
        test_count++;
        d1 = 8'h11;
        d2 = 8'h22;
        begin
            static data_t sum;
            // Assigned here so the result does not depend on the order of static initializers.
            sum = d1 + d2;
            if (sum == 8'h33) begin
                pass_count++;
                $display("Test 5 PASS: Sum = %h", sum);
            end else begin
                $display("Test 5 FAIL: Sum unexpected = %h", sum);
            end
        end

        // Test 6: Function multiple calls
        test_count++;
        begin
            static int r1;
            static int r2;
            // Assigned here so the result does not depend on the order of static initializers.
            r1 = add(1, 2);
            r2 = add(3, 4);
            if (r1 == 3 && r2 == 7) begin
                pass_count++;
                $display("Test 6 PASS: Multi r1=%0d r2=%0d", r1, r2);
            end else begin
                $display("Test 6 FAIL: Multi unexpected");
            end
        end

        // Test 7: Nested function call
        test_count++;
        begin
            static int r;
            // Assigned here so the result does not depend on the order of static initializers.
            r = add(add(1, 2), add(3, 4));
            if (r == 10) begin
                pass_count++;
                $display("Test 7 PASS: Nested = %0d", r);
            end else begin
                $display("Test 7 FAIL: Nested unexpected = %0d", r);
            end
        end

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
