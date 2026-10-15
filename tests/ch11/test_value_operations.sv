/*
:name: test_value_operations
:description: Value Operations
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.5 11.4.6 11.4.7 11.4.10 6.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_value_operations.expected
*/
// IEEE 1800-2023 Value Operations
// Sections: §11.4.5-6 (equality), §11.4.3 (arithmetic), §11.4.7 (logical),
//           §11.4.10 (shift), §11.4.3 (power/modulo)
// PASS_CRITERIA: All $display("PASS:*") messages must appear

module test_value_operations;

  initial begin
    static int pass_count = 0;
    static int total_tests = 30;

    // Test 1: ==? basic match (§11.4.6)
    begin
      static logic [3:0] a = 4'b1010;
      static logic [3:0] b = 4'b10?0;  // ? is Z wildcard
      if (a ==? 4'b10z0) begin
        $display("PASS: Test 1 - ==? basic wildcard match");
        pass_count++;
      end else $display("FAIL: Test 1 - ==? basic");
    end

    // Test 2: ==? LHS has X (§11.4.6)
    begin
      static logic [3:0] a = 4'b1x10;
      static logic [3:0] b = 4'b1010;
      logic result;
      result = (a ==? b);
      // X in LHS at non-wildcard position -> result is X
      if (result === 1'bx) begin
        $display("PASS: Test 2 - ==? LHS X returns X");
        pass_count++;
      end else $display("FAIL: Test 2 - ==? LHS X (got %b)", result);
    end

    // Test 3: ==? mismatch (§11.4.6)
    begin
      static logic [3:0] a = 4'b1010;
      static logic [3:0] b = 4'b0101;
      if (!(a ==? b)) begin
        $display("PASS: Test 3 - ==? mismatch returns 0");
        pass_count++;
      end else $display("FAIL: Test 3 - ==? mismatch");
    end

    // Test 4: !=? basic (§11.4.6)
    begin
      static logic [3:0] a = 4'b1010;
      static logic [3:0] b = 4'b0101;
      if (a !=? b) begin
        $display("PASS: Test 4 - !=? basic not equal");
        pass_count++;
      end else $display("FAIL: Test 4 - !=? basic");
    end

    // Test 5: ==? RHS Z wildcard (§11.4.6)
    begin
      static logic [3:0] a = 4'b1111;
      if (a ==? 4'b1zz1) begin
        $display("PASS: Test 5 - ==? RHS Z wildcards match any");
        pass_count++;
      end else $display("FAIL: Test 5 - ==? RHS Z");
    end

    // Test 6: === case equality with X/Z (§11.4.5)
    begin
      static logic [3:0] a = 4'bx01z;
      static logic [3:0] b = 4'bx01z;
      if (a === b) begin
        $display("PASS: Test 6 - === exact match including X/Z");
        pass_count++;
      end else $display("FAIL: Test 6 - === exact");
    end

    // Test 7: === mismatch X vs 0 (§11.4.5)
    begin
      static logic [3:0] a = 4'bx000;
      static logic [3:0] b = 4'b0000;
      if (!(a === b)) begin
        $display("PASS: Test 7 - === X vs 0 not equal");
        pass_count++;
      end else $display("FAIL: Test 7 - === X vs 0");
    end

    // Test 8: !== basic (§11.4.5)
    begin
      static logic [3:0] a = 4'b1010;
      static logic [3:0] b = 4'b1011;
      if (a !== b) begin
        $display("PASS: Test 8 - !== basic not equal");
        pass_count++;
      end else $display("FAIL: Test 8 - !==");
    end

    // Test 9: ** 0**0 = 1 (§11.4.3)
    begin
      static int result = 0 ** 0;
      if (result == 1) begin
        $display("PASS: Test 9 - 0**0 = 1");
        pass_count++;
      end else $display("FAIL: Test 9 - 0**0 (got %0d)", result);
    end

    // Test 10: ** 1**N = 1 for any N (§11.4.3)
    begin
      static int result = 1 ** 100;
      if (result == 1) begin
        $display("PASS: Test 10 - 1**100 = 1");
        pass_count++;
      end else $display("FAIL: Test 10 - 1**100 (got %0d)", result);
    end

    // Test 11: ** real base (§11.4.3)
    begin
      static real result = 2.0 ** 3;
      if (result > 7.99 && result < 8.01) begin
        $display("PASS: Test 11 - 2.0**3 = 8.0");
        pass_count++;
      end else $display("FAIL: Test 11 - real power (got %f)", result);
    end

    // Test 12: ** integer 2**10=1024 (§11.4.3)
    begin
      static int result = 2 ** 10;
      if (result == 1024) begin
        $display("PASS: Test 12 - 2**10 = 1024");
        pass_count++;
      end else $display("FAIL: Test 12 - int power (got %0d)", result);
    end

    // Test 13: << shift beyond width (§11.4.10)
    begin
      static logic [7:0] val = 8'hFF;
      static logic [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = val << 10;
      if (result == 8'h00) begin
        $display("PASS: Test 13 - left shift beyond width = 0");
        pass_count++;
      end else $display("FAIL: Test 13 - << overflow (got %h)", result);
    end

    // Test 14: >> shift beyond width (§11.4.10)
    begin
      static logic [7:0] val = 8'hFF;
      static logic [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = val >> 10;
      if (result == 8'h00) begin
        $display("PASS: Test 14 - right shift beyond width = 0");
        pass_count++;
      end else $display("FAIL: Test 14 - >> overflow (got %h)", result);
    end

    // Test 15: >>> signed preserves sign (§11.4.10)
    begin
      static int val = -4;
      static int result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = val >>> 1;
      if (result == -2) begin
        $display("PASS: Test 15 - >>> signed preserves sign bit");
        pass_count++;
      end else $display("FAIL: Test 15 - >>> signed (got %0d)", result);
    end

    // Test 16: >>> with X sign bit (§11.4.10)
    begin
      static logic signed [7:0] val = 8'bx1111100;
      static logic signed [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = val >>> 2;
      // X sign bit should propagate
      if (result[7] === 1'bx) begin
        $display("PASS: Test 16 - >>> X sign bit propagates");
        pass_count++;
      end else $display("FAIL: Test 16 - >>> X sign (got %b)", result);
    end

    // Test 17: % zero divisor = X (§11.4.3)
    begin
      static logic [7:0] a = 8'd10;
      static logic [7:0] b = 8'd0;
      static logic [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = a % b;
      if (result === 8'bxxxx_xxxx) begin
        $display("PASS: Test 17 - modulo by zero = X");
        pass_count++;
      end else $display("FAIL: Test 17 - mod zero (got %b)", result);
    end

    // Test 18: % signed negative dividend (§11.4.3)
    begin
      static int a = -7;
      static int b = 3;
      static int result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = a % b;
      // Sign of result follows sign of dividend
      if (result == -1) begin
        $display("PASS: Test 18 - (-7) %% 3 = -1");
        pass_count++;
      end else $display("FAIL: Test 18 - neg dividend mod (got %0d)", result);
    end

    // Test 19: % signed negative divisor (§11.4.3)
    begin
      static int a = 7;
      static int b = -3;
      static int result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = a % b;
      // Sign of result follows sign of dividend
      if (result == 1) begin
        $display("PASS: Test 19 - 7 %% (-3) = 1");
        pass_count++;
      end else $display("FAIL: Test 19 - neg divisor mod (got %0d)", result);
    end

    // Test 20: && X truth table (§11.4.7)
    begin
      static logic a = 1'bx;
      static logic b = 1'b0;
      static logic result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = a && b;
      if (result === 1'b0) begin
        $display("PASS: Test 20 - X && 0 = 0 (0 dominates)");
        pass_count++;
      end else $display("FAIL: Test 20 - X&&0 (got %b)", result);
    end

    // Test 21: && X && X = X (§11.4.7)
    begin
      static logic a = 1'bx;
      static logic b = 1'bx;
      static logic result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = a && b;
      if (result === 1'bx) begin
        $display("PASS: Test 21 - X && X = X");
        pass_count++;
      end else $display("FAIL: Test 21 - X&&X (got %b)", result);
    end

    // Test 22: || X truth table (§11.4.7)
    begin
      static logic a = 1'bx;
      static logic b = 1'b1;
      static logic result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = a || b;
      if (result === 1'b1) begin
        $display("PASS: Test 22 - X || 1 = 1 (1 dominates)");
        pass_count++;
      end else $display("FAIL: Test 22 - X||1 (got %b)", result);
    end

    // Test 23: || X || X = X (§11.4.7)
    begin
      static logic a = 1'bx;
      static logic b = 1'bx;
      static logic result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = a || b;
      if (result === 1'bx) begin
        $display("PASS: Test 23 - X || X = X");
        pass_count++;
      end else $display("FAIL: Test 23 - X||X (got %b)", result);
    end

    // Test 24: ! X = X (§11.4.7)
    begin
      static logic a = 1'bx;
      static logic result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = !a;
      if (result === 1'bx) begin
        $display("PASS: Test 24 - !X = X");
        pass_count++;
      end else $display("FAIL: Test 24 - !X (got %b)", result);
    end

    // Test 25: == string comparison (§11.4.5)
    begin
      static string a = "hello";
      static string b = "hello";
      static string c = "world";
      if (a == b && a != c) begin
        $display("PASS: Test 25 - String == and != comparison");
        pass_count++;
      end else $display("FAIL: Test 25 - String compare");
    end

    // Test 26: == real comparison (§11.4.5)
    begin
      static real a = 3.14;
      static real b = 3.14;
      static real c = 2.71;
      if (a == b && a != c) begin
        $display("PASS: Test 26 - Real == and != comparison");
        pass_count++;
      end else $display("FAIL: Test 26 - Real compare");
    end

    // Test 27: + mixed real+int (§11.4.3)
    begin
      static int a = 3;
      static real b = 1.5;
      static real result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = a + b;
      if (result > 4.49 && result < 4.51) begin
        $display("PASS: Test 27 - int+real = 4.5");
        pass_count++;
      end else $display("FAIL: Test 27 - mixed add (got %f)", result);
    end

    // Test 28: - signed result (§11.4.3)
    begin
      static int a = 5;
      static int b = 10;
      static int result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = a - b;
      if (result == -5) begin
        $display("PASS: Test 28 - 5-10 = -5 signed");
        pass_count++;
      end else $display("FAIL: Test 28 - signed sub (got %0d)", result);
    end

    // Test 29: * overflow truncation (§11.4.3)
    begin
      static logic [7:0] a = 8'd200;
      static logic [7:0] b = 8'd2;
      static logic [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = a * b;
      // 200*2 = 400 = 0x190, truncated to 8 bits = 0x90 = 144
      if (result == 8'd144) begin
        $display("PASS: Test 29 - 200*2 truncated to 8-bit = 144");
        pass_count++;
      end else $display("FAIL: Test 29 - mul truncate (got %0d)", result);
    end

    // Test 30: / real division (§11.4.3)
    begin
      static real a = 1.0;
      static real b = 0.0;
      static real result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = a / b;
      // Should return infinity per IEEE 754
      if (result > 1.0e300) begin
        $display("PASS: Test 30 - 1.0/0.0 = infinity");
        pass_count++;
      end else $display("FAIL: Test 30 - real div zero (got %f)", result);
    end

    $display("\n=== Value Operations Summary ===");
    $display("Tests passed: %0d/%0d", pass_count, total_tests);
    if (pass_count == total_tests) $display("ALL TESTS PASSED");
    else $display("SOME TESTS FAILED");
    $finish;
  end
endmodule
