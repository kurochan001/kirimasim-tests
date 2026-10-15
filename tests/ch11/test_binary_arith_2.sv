/*
:name: test_binary_arith_2
:description: Binary arithmetic operators on int, 32-bit vector and real operands
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_binary_arith_2.expected
*/
// Binary arithmetic operators on int, 32-bit vector and real operands

module test_binary_arith;
    int pass_count = 0;
    int total_tests = 25;

    // Test variables
    int a, b, result;
    logic [31:0] ua, ub, uresult;
    real ra, rb, rresult;
    logic [7:0] small_a, small_b;

    initial begin
        // Test 1: Basic addition
        a = 10; b = 20;
        result = a + b;
        if (result == 30) begin
            $display("Test 1 PASSED: 10 + 20 = 30");
            pass_count++;
        end else $display("Test 1 FAILED: 10 + 20 = %0d", result);

        // Test 2: Basic subtraction
        a = 50; b = 30;
        result = a - b;
        if (result == 20) begin
            $display("Test 2 PASSED: 50 - 30 = 20");
            pass_count++;
        end else $display("Test 2 FAILED: 50 - 30 = %0d", result);

        // Test 3: Basic multiplication
        a = 7; b = 8;
        result = a * b;
        if (result == 56) begin
            $display("Test 3 PASSED: 7 * 8 = 56");
            pass_count++;
        end else $display("Test 3 FAILED: 7 * 8 = %0d", result);

        // Test 4: Basic division
        a = 100; b = 4;
        result = a / b;
        if (result == 25) begin
            $display("Test 4 PASSED: 100 / 4 = 25");
            pass_count++;
        end else $display("Test 4 FAILED: 100 / 4 = %0d", result);

        // Test 5: Basic modulo
        a = 17; b = 5;
        result = a % b;
        if (result == 2) begin
            $display("Test 5 PASSED: 17 %% 5 = 2");
            pass_count++;
        end else $display("Test 5 FAILED: 17 %% 5 = %0d", result);

        // Test 6: Negative addition
        a = -10; b = -20;
        result = a + b;
        if (result == -30) begin
            $display("Test 6 PASSED: -10 + -20 = -30");
            pass_count++;
        end else $display("Test 6 FAILED: -10 + -20 = %0d", result);

        // Test 7: Subtraction with negative result
        a = 10; b = 30;
        result = a - b;
        if (result == -20) begin
            $display("Test 7 PASSED: 10 - 30 = -20");
            pass_count++;
        end else $display("Test 7 FAILED: 10 - 30 = %0d", result);

        // Test 8: Multiplication with negative
        a = -5; b = 7;
        result = a * b;
        if (result == -35) begin
            $display("Test 8 PASSED: -5 * 7 = -35");
            pass_count++;
        end else $display("Test 8 FAILED: -5 * 7 = %0d", result);

        // Test 9: Division with negative
        a = -100; b = 4;
        result = a / b;
        if (result == -25) begin
            $display("Test 9 PASSED: -100 / 4 = -25");
            pass_count++;
        end else $display("Test 9 FAILED: -100 / 4 = %0d", result);

        // Test 10: Modulo with negative
        a = -17; b = 5;
        result = a % b;
        if (result == -2) begin
            $display("Test 10 PASSED: -17 %% 5 = -2");
            pass_count++;
        end else $display("Test 10 FAILED: -17 %% 5 = %0d", result);

        // Test 11: Unsigned addition
        ua = 32'hFFFFFFFF; ub = 32'h00000001;
        uresult = ua + ub;
        if (uresult == 32'h00000000) begin
            $display("Test 11 PASSED: 0xFFFFFFFF + 1 = 0 (overflow)");
            pass_count++;
        end else $display("Test 11 FAILED: 0xFFFFFFFF + 1 = %h", uresult);

        // Test 12: Unsigned multiplication
        ua = 32'h00010000; ub = 32'h00000100;
        uresult = ua * ub;
        if (uresult == 32'h01000000) begin
            $display("Test 12 PASSED: 0x10000 * 0x100 = 0x1000000");
            pass_count++;
        end else $display("Test 12 FAILED: 0x10000 * 0x100 = %h", uresult);

        // Test 13: Real addition
        ra = 3.14; rb = 2.86;
        rresult = ra + rb;
        if (rresult == 6.0) begin
            $display("Test 13 PASSED: 3.14 + 2.86 = 6.0");
            pass_count++;
        end else $display("Test 13 FAILED: 3.14 + 2.86 = %f", rresult);

        // Test 14: Real subtraction
        ra = 10.5; rb = 3.5;
        rresult = ra - rb;
        if (rresult == 7.0) begin
            $display("Test 14 PASSED: 10.5 - 3.5 = 7.0");
            pass_count++;
        end else $display("Test 14 FAILED: 10.5 - 3.5 = %f", rresult);

        // Test 15: Real multiplication
        ra = 2.5; rb = 4.0;
        rresult = ra * rb;
        if (rresult == 10.0) begin
            $display("Test 15 PASSED: 2.5 * 4.0 = 10.0");
            pass_count++;
        end else $display("Test 15 FAILED: 2.5 * 4.0 = %f", rresult);

        // Test 16: Real division
        ra = 15.0; rb = 3.0;
        rresult = ra / rb;
        if (rresult == 5.0) begin
            $display("Test 16 PASSED: 15.0 / 3.0 = 5.0");
            pass_count++;
        end else $display("Test 16 FAILED: 15.0 / 3.0 = %f", rresult);

        // Test 17: Mixed width arithmetic
        small_a = 8'd200; small_b = 8'd100;
        if ((small_a + small_b) == 9'd300) begin
            $display("Test 17 PASSED: 8'd200 + 8'd100 = 300");
            pass_count++;
        end else $display("Test 17 FAILED: 8'd200 + 8'd100 = %0d", small_a + small_b);

        // Test 18: Division truncation
        a = 10; b = 3;
        result = a / b;
        if (result == 3) begin
            $display("Test 18 PASSED: 10 / 3 = 3 (truncated)");
            pass_count++;
        end else $display("Test 18 FAILED: 10 / 3 = %0d", result);

        // Test 19: Multiply by zero
        a = 12345; b = 0;
        result = a * b;
        if (result == 0) begin
            $display("Test 19 PASSED: 12345 * 0 = 0");
            pass_count++;
        end else $display("Test 19 FAILED: 12345 * 0 = %0d", result);

        // Test 20: Add zero
        a = 999; b = 0;
        result = a + b;
        if (result == 999) begin
            $display("Test 20 PASSED: 999 + 0 = 999");
            pass_count++;
        end else $display("Test 20 FAILED: 999 + 0 = %0d", result);

        // Test 21: Subtract self
        a = 42;
        result = a - a;
        if (result == 0) begin
            $display("Test 21 PASSED: 42 - 42 = 0");
            pass_count++;
        end else $display("Test 21 FAILED: 42 - 42 = %0d", result);

        // Test 22: Power of 2 division
        a = 256; b = 2;
        result = a / b;
        if (result == 128) begin
            $display("Test 22 PASSED: 256 / 2 = 128");
            pass_count++;
        end else $display("Test 22 FAILED: 256 / 2 = %0d", result);

        // Test 23: Chain arithmetic
        a = 10;
        result = a + 5 - 3 * 2;
        if (result == 9) begin
            $display("Test 23 PASSED: 10 + 5 - 3 * 2 = 9");
            pass_count++;
        end else $display("Test 23 FAILED: 10 + 5 - 3 * 2 = %0d", result);

        // Test 24: Modulo of exact multiple
        a = 100; b = 10;
        result = a % b;
        if (result == 0) begin
            $display("Test 24 PASSED: 100 %% 10 = 0");
            pass_count++;
        end else $display("Test 24 FAILED: 100 %% 10 = %0d", result);

        // Test 25: Large multiplication
        a = 100000; b = 1000;
        result = a * b;
        if (result == 100000000) begin
            $display("Test 25 PASSED: 100000 * 1000 = 100000000");
            pass_count++;
        end else $display("Test 25 FAILED: 100000 * 1000 = %0d", result);

        $display("PASS: binary_arith (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
