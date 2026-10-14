/*
:name: test_ieee1800_2023_arithmetic_edge
:description: Arithmetic Edge Cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.6 6.12
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_ieee1800_2023_arithmetic_edge.expected
*/
// IEEE 1800-2023 Arithmetic Edge Cases
// Sections: 11.4.3 (arithmetic), 11.8.2 (division), 11.6 (exponentiation)
// PASS_CRITERIA: All $display("PASS:*") messages must appear

module test_ieee1800_2023_arithmetic_edge;

  initial begin
    static int pass_count = 0;
    static int total_tests = 25;

    // ===========================================
    // Division Edge Cases (IEEE 1800-2023 Section 11.4.3)
    // ===========================================

    // Test 1: Integer division by zero -> X
    begin
      static logic [31:0] a = 32'd100;
      static logic [31:0] b = 32'd0;
      static logic [31:0] result = a / b;
      if (result === 32'hxxxxxxxx) begin
        $display("PASS: Test 1 - integer division by zero -> X");
        pass_count++;
      end else $display("FAIL: Test 1 - div by zero (got %h)", result);
    end

    // Test 2: Real division by zero -> IEEE 754 infinity (§11.4.3)
    begin
      static real a = 1.0;
      static real b = 0.0;
      static real result = a / b;
      if (result > 1.0e300) begin
        $display("PASS: Test 2 - real division by zero -> infinity");
        pass_count++;
      end else $display("FAIL: Test 2 - real div zero (got %f)", result);
    end

    // Test 3: Signed division negative / positive
    begin
      static int a = -100;
      static int b = 7;
      static int result = a / b;
      if (result == -14) begin
        $display("PASS: Test 3 - signed div negative/positive");
        pass_count++;
      end else $display("FAIL: Test 3 - signed div (got %0d)", result);
    end

    // Test 4: Signed division negative / negative
    begin
      static int a = -100;
      static int b = -7;
      static int result = a / b;
      if (result == 14) begin
        $display("PASS: Test 4 - signed div negative/negative");
        pass_count++;
      end else $display("FAIL: Test 4 - signed div neg/neg (got %0d)", result);
    end

    // Test 5: Signed division INT_MIN / -1 (overflow case)
    begin
      static int a = -2147483648;
      static int b = -1;
      static int result = a / b;
      if (result == -2147483648) begin
        $display("PASS: Test 5 - INT_MIN / -1 overflow");
        pass_count++;
      end else $display("FAIL: Test 5 - INT_MIN/-1 (got %0d)", result);
    end

    // ===========================================
    // Modulo Edge Cases (IEEE 1800-2023 Section 11.4.3)
    // ===========================================

    // Test 6: Integer modulo by zero -> X
    begin
      static logic [31:0] a = 32'd100;
      static logic [31:0] b = 32'd0;
      static logic [31:0] result = a % b;
      if (result === 32'hxxxxxxxx) begin
        $display("PASS: Test 6 - integer modulo by zero -> X");
        pass_count++;
      end else $display("FAIL: Test 6 - mod by zero (got %h)", result);
    end

    // Test 7: Signed modulo negative dividend
    begin
      static int a = -17;
      static int b = 5;
      static int result = a % b;
      if (result == -2) begin
        $display("PASS: Test 7 - signed modulo negative dividend");
        pass_count++;
      end else $display("FAIL: Test 7 - signed mod (got %0d)", result);
    end

    // Test 8: Signed modulo negative divisor
    begin
      static int a = 17;
      static int b = -5;
      static int result = a % b;
      if (result == 2) begin
        $display("PASS: Test 8 - signed modulo negative divisor");
        pass_count++;
      end else $display("FAIL: Test 8 - mod neg div (got %0d)", result);
    end

    // Test 9: Modulo with equal values -> 0
    begin
      static int a = 42;
      static int b = 42;
      static int result = a % b;
      if (result == 0) begin
        $display("PASS: Test 9 - modulo equal values -> 0");
        pass_count++;
      end else $display("FAIL: Test 9 - mod equal (got %0d)", result);
    end

    // ===========================================
    // Power Operator Edge Cases (IEEE 1800-2023 Section 11.4.3)
    // ===========================================

    // Test 10: Power 2**31
    begin
      static longint result = longint'(2) ** 31;
      if (result == 2147483648) begin
        $display("PASS: Test 10 - power 2**31");
        pass_count++;
      end else $display("FAIL: Test 10 - 2**31 (got %0d)", result);
    end

    // Test 11: Power 2**0 -> 1
    begin
      static int result = 2 ** 0;
      if (result == 1) begin
        $display("PASS: Test 11 - power 2**0 -> 1");
        pass_count++;
      end else $display("FAIL: Test 11 - 2**0 (got %0d)", result);
    end

    // Test 12: Power 0**0 -> 1
    begin
      static int result = 0 ** 0;
      if (result == 1) begin
        $display("PASS: Test 12 - power 0**0 -> 1");
        pass_count++;
      end else $display("FAIL: Test 12 - 0**0 (got %0d)", result);
    end

    // Test 13: Power 0**N -> 0
    begin
      static int result = 0 ** 5;
      if (result == 0) begin
        $display("PASS: Test 13 - power 0**5 -> 0");
        pass_count++;
      end else $display("FAIL: Test 13 - 0**5 (got %0d)", result);
    end

    // Test 14: Power 1**N -> 1
    begin
      static int result = 1 ** 100;
      if (result == 1) begin
        $display("PASS: Test 14 - power 1**100 -> 1");
        pass_count++;
      end else $display("FAIL: Test 14 - 1**100 (got %0d)", result);
    end

    // Test 15: Real power with fractional exponent
    begin
      static real result = 9.0 ** 0.5;
      if (result > 2.99 && result < 3.01) begin
        $display("PASS: Test 15 - real power 9.0**0.5 -> 3.0");
        pass_count++;
      end else $display("FAIL: Test 15 - 9.0**0.5 (got %f)", result);
    end

    // ===========================================
    // Signed Multiplication Overflow (IEEE 1800-2023 Section 11.4.3)
    // ===========================================

    // Test 16: Signed multiplication overflow
    begin
      static int a = 32'h7FFFFFFF;  // INT_MAX
      static int b = 2;
      static int result = a * b;
      if (result == -2) begin
        $display("PASS: Test 16 - signed multiply overflow wraps");
        pass_count++;
      end else $display("FAIL: Test 16 - mul overflow (got %0d)", result);
    end

    // Test 17: Unsigned multiplication
    begin
      static logic [7:0] a = 8'd200;
      static logic [7:0] b = 8'd2;
      static logic [7:0] result = a * b;
      if (result == 8'd144) begin
        $display("PASS: Test 17 - unsigned multiply truncation");
        pass_count++;
      end else $display("FAIL: Test 17 - unsigned mul (got %0d)", result);
    end

    // ===========================================
    // Addition/Subtraction Edge Cases
    // ===========================================

    // Test 18: Addition result truncation (width exceeded)
    begin
      static logic [7:0] a = 8'hFF;
      static logic [7:0] b = 8'h01;
      static logic [7:0] result = a + b;
      if (result == 8'h00) begin
        $display("PASS: Test 18 - addition overflow truncation");
        pass_count++;
      end else $display("FAIL: Test 18 - add overflow (got %h)", result);
    end

    // Test 19: Subtraction underflow
    begin
      static logic [7:0] a = 8'h00;
      static logic [7:0] b = 8'h01;
      static logic [7:0] result = a - b;
      if (result == 8'hFF) begin
        $display("PASS: Test 19 - subtraction underflow wraps");
        pass_count++;
      end else $display("FAIL: Test 19 - sub underflow (got %h)", result);
    end

    // Test 20: Signed addition overflow
    begin
      static int a = 32'h7FFFFFFF;  // INT_MAX
      static int b = 1;
      static int result = a + b;
      if (result == -2147483648) begin
        $display("PASS: Test 20 - signed addition overflow -> INT_MIN");
        pass_count++;
      end else $display("FAIL: Test 20 - signed add overflow (got %0d)", result);
    end

    // ===========================================
    // Mixed Real/Integer Arithmetic
    // ===========================================

    // Test 21: int + real -> real
    begin
      static int a = 3;
      static real b = 0.14;
      static real result = a + b;
      if (result > 3.13 && result < 3.15) begin
        $display("PASS: Test 21 - int + real -> real");
        pass_count++;
      end else $display("FAIL: Test 21 - int+real (got %f)", result);
    end

    // Test 22: real * int -> real
    begin
      static real a = 2.5;
      static int b = 4;
      static real result = a * b;
      if (result > 9.99 && result < 10.01) begin
        $display("PASS: Test 22 - real * int -> real");
        pass_count++;
      end else $display("FAIL: Test 22 - real*int (got %f)", result);
    end

    // Test 23: Unary minus on unsigned
    begin
      static logic [7:0] a = 8'd5;
      static logic [7:0] result = -a;
      if (result == 8'hFB) begin
        $display("PASS: Test 23 - unary minus on unsigned");
        pass_count++;
      end else $display("FAIL: Test 23 - unary minus (got %h)", result);
    end

    // Test 24: Bitwise NOT
    begin
      static logic [7:0] a = 8'hA5;
      static logic [7:0] result = ~a;
      if (result == 8'h5A) begin
        $display("PASS: Test 24 - bitwise NOT");
        pass_count++;
      end else $display("FAIL: Test 24 - NOT (got %h)", result);
    end

    // Test 25: Logical NOT
    begin
      static int a = 0;
      static int b = 42;
      if (!a == 1 && !b == 0) begin
        $display("PASS: Test 25 - logical NOT");
        pass_count++;
      end else $display("FAIL: Test 25 - logical NOT");
    end

    $display("\n=== Arithmetic Edge Cases Summary ===");
    $display("Tests passed: %0d/%0d", pass_count, total_tests);
    if (pass_count == total_tests) $display("ALL TESTS PASSED");
    else $display("SOME TESTS FAILED");
    $finish;
  end

endmodule
