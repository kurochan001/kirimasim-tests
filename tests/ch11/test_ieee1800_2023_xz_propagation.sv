/*
:name: test_ieee1800_2023_xz_propagation
:description: X and Z propagation through operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.5 11.4.6 11.4.9 11.4.10 11.4.11 11.4.8 11.4.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_ieee1800_2023_xz_propagation.expected
*/
// IEEE 1800-2023 X/Z Propagation Edge Cases
// Sections: 11.4.6 (wildcard equality), 11.4.9 (reduction), 11.4.10 (shifts), 11.4.11 (conditional)
// PASS_CRITERIA: All $display("PASS:*") messages must appear

module test_ieee1800_2023_xz_propagation;

  initial begin
    static int pass_count = 0;
    static int total_tests = 30;

    // ===========================================
    // Wildcard Equality (IEEE 1800-2023 Section 11.4.6)
    // ===========================================

    // Test 1: ==? basic X match
    begin
      static logic [3:0] a = 4'b1010;
      static logic [3:0] b = 4'b1x1x;  // X positions are wildcards in b
      if (a ==? b) begin
        $display("PASS: Test 1 - ==? X wildcard match");
        pass_count++;
      end else $display("FAIL: Test 1 - ==? wildcard");
    end

    // Test 2: ==? basic Z match
    begin
      static logic [3:0] a = 4'b1100;
      static logic [3:0] b = 4'b11zz;  // Z positions are wildcards in b
      if (a ==? b) begin
        $display("PASS: Test 2 - ==? Z wildcard match");
        pass_count++;
      end else $display("FAIL: Test 2 - ==? Z wildcard");
    end

    // Test 3: ==? mismatch
    begin
      static logic [3:0] a = 4'b1010;
      static logic [3:0] b = 4'b0x1x;  // MSB doesn't match
      if (!(a ==? b)) begin
        $display("PASS: Test 3 - ==? mismatch");
        pass_count++;
      end else $display("FAIL: Test 3 - ==? should mismatch");
    end

    // Test 4: !=? basic
    begin
      static logic [3:0] a = 4'b1010;
      static logic [3:0] b = 4'b0x1x;  // MSB differs
      if (a !=? b) begin
        $display("PASS: Test 4 - !=? basic mismatch");
        pass_count++;
      end else $display("FAIL: Test 4 - !=? basic");
    end

    // Test 5: ==? all wildcards
    begin
      static logic [3:0] a = 4'b1010;
      static logic [3:0] b = 4'bxxxx;
      if (a ==? b) begin
        $display("PASS: Test 5 - ==? all X wildcards");
        pass_count++;
      end else $display("FAIL: Test 5 - ==? all X");
    end

    // ===========================================
    // Arithmetic Shift with X/Z (IEEE 1800-2023 Section 11.4.10)
    // ===========================================

    // Test 6: Arithmetic right shift positive value
    begin
      static logic signed [7:0] val = 8'sb01100000;  // +96
      static logic signed [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = val >>> 3;
      if (result == 8'sb00001100) begin  // +12
        $display("PASS: Test 6 - arith right shift positive");
        pass_count++;
      end else $display("FAIL: Test 6 - arith shift pos (got %b)", result);
    end

    // Test 7: Arithmetic right shift negative value (sign extend)
    begin
      static logic signed [7:0] val = -64;  // 8'b11000000
      static logic signed [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = val >>> 2;
      if (result == -16) begin  // 8'b11110000
        $display("PASS: Test 7 - arith right shift negative (sign extend)");
        pass_count++;
      end else $display("FAIL: Test 7 - arith shift neg (got %0d)", result);
    end

    // Test 8: Left shift << fills with zeros
    begin
      static logic [7:0] val = 8'hFF;
      static logic [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = val << 4;
      if (result == 8'hF0) begin
        $display("PASS: Test 8 - left shift fills zeros");
        pass_count++;
      end else $display("FAIL: Test 8 - left shift (got %h)", result);
    end

    // Test 9: Shift amount larger than bit width
    begin
      static logic [7:0] val = 8'hFF;
      static logic [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = val << 10;
      if (result == 8'h00) begin
        $display("PASS: Test 9 - shift amount > width -> 0");
        pass_count++;
      end else $display("FAIL: Test 9 - over shift (got %h)", result);
    end

    // Test 10: Zero shift amount
    begin
      static logic [7:0] val = 8'hAB;
      static logic [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = val >> 0;
      if (result == 8'hAB) begin
        $display("PASS: Test 10 - shift by 0 unchanged");
        pass_count++;
      end else $display("FAIL: Test 10 - shift 0 (got %h)", result);
    end

    // ===========================================
    // Conditional Operator with X/Z (IEEE 1800-2023 Section 11.4.11)
    // ===========================================

    // Test 11: Conditional with 1'b1 selector
    begin
      static logic [7:0] a = 8'hAA;
      static logic [7:0] b = 8'h55;
      static logic sel = 1'b1;
      static logic [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = sel ? a : b;
      if (result == 8'hAA) begin
        $display("PASS: Test 11 - conditional sel=1");
        pass_count++;
      end else $display("FAIL: Test 11 - cond sel=1 (got %h)", result);
    end

    // Test 12: Conditional with 1'b0 selector
    begin
      static logic [7:0] a = 8'hAA;
      static logic [7:0] b = 8'h55;
      static logic sel = 1'b0;
      static logic [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = sel ? a : b;
      if (result == 8'h55) begin
        $display("PASS: Test 12 - conditional sel=0");
        pass_count++;
      end else $display("FAIL: Test 12 - cond sel=0 (got %h)", result);
    end

    // Test 13: Conditional with X selector -> bitwise merge
    begin
      static logic [7:0] a = 8'hFF;
      static logic [7:0] b = 8'hFF;
      static logic sel = 1'bx;
      static logic [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = sel ? a : b;
      // When both branches are same, result is same regardless of X
      if (result == 8'hFF) begin
        $display("PASS: Test 13 - conditional sel=X, same branches -> FF");
        pass_count++;
      end else $display("FAIL: Test 13 - cond sel=X same (got %h)", result);
    end

    // Test 14: Conditional X selector different branches -> X bits
    begin
      static logic [7:0] a = 8'hF0;
      static logic [7:0] b = 8'h0F;
      static logic sel = 1'bx;
      static logic [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = sel ? a : b;
      // Bitwise merge: bits that match stay, others -> X
      // a=11110000, b=00001111 -> all differ -> xxxxxxxx
      if (result === 8'hxx) begin
        $display("PASS: Test 14 - conditional sel=X, diff branches -> X");
        pass_count++;
      end else $display("FAIL: Test 14 - cond sel=X diff (got %h)", result);
    end

    // Test 15: Conditional partial X merge
    begin
      static logic [7:0] a = 8'hFF;
      static logic [7:0] b = 8'h0F;
      static logic sel = 1'bx;
      static logic [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = sel ? a : b;
      // a=11111111, b=00001111 -> upper 4 bits differ -> Xx0F pattern
      // Lower 4 bits match (1111) -> stay as F
      if (result[3:0] === 4'hF) begin
        $display("PASS: Test 15 - conditional sel=X partial merge lower OK");
        pass_count++;
      end else $display("FAIL: Test 15 - partial merge (got %h)", result);
    end

    // ===========================================
    // X/Z in Comparison (IEEE 1800-2023 Section 11.4.5)
    // ===========================================

    // Test 16: Case equality === with X
    begin
      static logic [3:0] a = 4'b1x0z;
      static logic [3:0] b = 4'b1x0z;
      if (a === b) begin
        $display("PASS: Test 16 - case equality === with X/Z");
        pass_count++;
      end else $display("FAIL: Test 16 - case equality");
    end

    // Test 17: Case inequality !== with X
    begin
      static logic [3:0] a = 4'b1x0z;
      static logic [3:0] b = 4'b1x0x;  // Last bit differs (z vs x)
      if (a !== b) begin
        $display("PASS: Test 17 - case inequality !== X vs Z");
        pass_count++;
      end else $display("FAIL: Test 17 - case inequality");
    end

    // Test 18: Logical equality == with X operand returns X (§11.4.5)
    begin
      static logic [3:0] a = 4'b1x00;
      static logic [3:0] b = 4'b1100;
      static logic result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = (a == b);
      if (result === 1'bx) begin
        $display("PASS: Test 18 - logical == with X -> X");
        pass_count++;
      end else $display("FAIL: Test 18 - == with X (got %b)", result);
    end

    // Test 19: Logical equality known values
    begin
      static logic [3:0] a = 4'b1100;
      static logic [3:0] b = 4'b1100;
      if (a == b) begin
        $display("PASS: Test 19 - logical == known equal");
        pass_count++;
      end else $display("FAIL: Test 19 - known equal");
    end

    // ===========================================
    // Reduction with X/Z (IEEE 1800-2023 Section 11.4.9)
    // ===========================================

    // Test 20: Reduction OR with one 1 bit (overrides X)
    begin
      static logic [3:0] val = 4'b1x0x;
      static logic result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = |val;
      // At least one bit is 1, so result is 1
      if (result === 1'b1) begin
        $display("PASS: Test 20 - reduction OR with X (has 1) -> 1");
        pass_count++;
      end else $display("FAIL: Test 19 - red OR X (got %b)", result);
    end

    // Test 21: Reduction AND with one 0 bit (overrides X)
    begin
      static logic [3:0] val = 4'b1x0x;
      static logic result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = &val;
      // At least one bit is 0, so result is 0
      if (result === 1'b0) begin
        $display("PASS: Test 21 - reduction AND with X (has 0) -> 0");
        pass_count++;
      end else $display("FAIL: Test 21 - red AND X (got %b)", result);
    end

    // Test 22: Reduction OR all X -> X
    begin
      static logic [3:0] val = 4'bxxxx;
      static logic result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = |val;
      if (result === 1'bx) begin
        $display("PASS: Test 22 - reduction OR all X -> X");
        pass_count++;
      end else $display("FAIL: Test 22 - red OR all X (got %b)", result);
    end

    // Test 23: Reduction AND all X -> X
    begin
      static logic [3:0] val = 4'bxxxx;
      static logic result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = &val;
      if (result === 1'bx) begin
        $display("PASS: Test 23 - reduction AND all X -> X");
        pass_count++;
      end else $display("FAIL: Test 23 - red AND all X (got %b)", result);
    end

    // ===========================================
    // X/Z in Arithmetic (IEEE 1800-2023 Section 11.4.3)
    // ===========================================

    // Test 24: Addition with X operand -> X
    begin
      static logic [7:0] a = 8'hFF;
      static logic [7:0] b = 8'hxx;
      static logic [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = a + b;
      if (result === 8'hxx) begin
        $display("PASS: Test 24 - addition with X -> X");
        pass_count++;
      end else $display("FAIL: Test 24 - add X (got %h)", result);
    end

    // Test 25: Multiplication with X -> X
    begin
      static logic [7:0] a = 8'd5;
      static logic [7:0] b = 8'hxx;
      static logic [7:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = a * b;
      if (result === 8'hxx) begin
        $display("PASS: Test 25 - multiply with X -> X");
        pass_count++;
      end else $display("FAIL: Test 25 - mul X (got %h)", result);
    end

    // Test 26: Bitwise AND with X
    begin
      static logic [3:0] a = 4'b1100;
      static logic [3:0] b = 4'bxx11;
      static logic [3:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = a & b;
      // 1&x=x, 1&x=x, 0&1=0, 0&1=0
      if (result[1:0] === 2'b00) begin
        $display("PASS: Test 26 - bitwise AND with X (0&anything=0)");
        pass_count++;
      end else $display("FAIL: Test 26 - AND X (got %b)", result);
    end

    // Test 27: Bitwise OR with X
    begin
      static logic [3:0] a = 4'b1100;
      static logic [3:0] b = 4'bxx00;
      static logic [3:0] result;
      // Assigned here so the result does not depend on the order of static initializers.
      result = a | b;
      // 1|x=1, 1|x=1, 0|0=0, 0|0=0
      if (result[3:2] === 2'b11 && result[1:0] === 2'b00) begin
        $display("PASS: Test 27 - bitwise OR with X (1|anything=1)");
        pass_count++;
      end else $display("FAIL: Test 27 - OR X (got %b)", result);
    end

    // ===========================================
    // Signed Comparison Edge Cases
    // ===========================================

    // Test 28: Signed comparison INT_MIN < INT_MAX
    begin
      static int a = -2147483648;  // INT_MIN
      static int b = 2147483647;   // INT_MAX
      if (a < b) begin
        $display("PASS: Test 28 - signed INT_MIN < INT_MAX");
        pass_count++;
      end else $display("FAIL: Test 28 - INT_MIN < INT_MAX");
    end

    // Test 29: Signed comparison -1 > -2
    begin
      static int a = -1;
      static int b = -2;
      if (a > b) begin
        $display("PASS: Test 29 - signed -1 > -2");
        pass_count++;
      end else $display("FAIL: Test 29 - signed compare neg");
    end

    // Test 30: Unsigned comparison large values
    begin
      static logic [31:0] a = 32'hFFFFFFFF;  // max unsigned
      static logic [31:0] b = 32'h00000001;
      if (a > b) begin
        $display("PASS: Test 30 - unsigned max > 1");
        pass_count++;
      end else $display("FAIL: Test 30 - unsigned compare");
    end

    $display("\n=== X/Z Propagation Edge Cases Summary ===");
    $display("Tests passed: %0d/%0d", pass_count, total_tests);
    if (pass_count == total_tests) $display("ALL TESTS PASSED");
    else $display("SOME TESTS FAILED");
    $finish;
  end

endmodule
