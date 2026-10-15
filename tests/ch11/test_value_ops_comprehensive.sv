/*
:name: test_value_ops_comprehensive
:description: Wildcard and case equality, equality with x, width and signedness in comparisons
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5 11.4.6 11.4.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_value_ops_comprehensive.expected
*/
// Wildcard and case equality, equality with x, width and signedness in comparisons
// Tests wildcard equality, type conversions, and value comparisons

module test_value_ops_comprehensive;

  int pass_count = 0;
  int test_count = 0;

  initial begin
    // Test 1: Wildcard equality with Z (==?)
    test_count++;
    begin
      static logic [7:0] a = 8'b10101010;
      static logic [7:0] b = 8'b1010zzzz;  // Lower nibble is don't care
      if (a ==? b) begin
        $display("PASS: Wildcard equality 10101010 ==? 1010zzzz");
        pass_count++;
      end else begin
        $display("FAIL: Wildcard equality should match");
      end
    end

    // Test 2: Wildcard equality mismatch
    test_count++;
    begin
      static logic [7:0] a = 8'b10101010;
      static logic [7:0] b = 8'b1111zzzz;  // Upper nibble differs
      if (!(a ==? b)) begin
        $display("PASS: Wildcard equality 10101010 !=? 1111zzzz");
        pass_count++;
      end else begin
        $display("FAIL: Wildcard equality should not match");
      end
    end

    // Test 3: Wildcard inequality (!==?)
    test_count++;
    begin
      static logic [7:0] a = 8'b10101010;
      static logic [7:0] b = 8'b1111zzzz;
      if (a !=? b) begin
        $display("PASS: Wildcard inequality 10101010 !=? 1111zzzz");
        pass_count++;
      end else begin
        $display("FAIL: Wildcard inequality should be true");
      end
    end

    // Test 4: Case equality with X (===)
    test_count++;
    begin
      static logic [3:0] a = 4'b10x1;
      static logic [3:0] b = 4'b10x1;
      if (a === b) begin
        $display("PASS: Case equality 10x1 === 10x1");
        pass_count++;
      end else begin
        $display("FAIL: Case equality should match X bits");
      end
    end

    // Test 5: Case inequality with different X (!==)
    test_count++;
    begin
      static logic [3:0] a = 4'b10x1;
      static logic [3:0] b = 4'b10x0;
      if (a !== b) begin
        $display("PASS: Case inequality 10x1 !== 10x0");
        pass_count++;
      end else begin
        $display("FAIL: Case inequality should detect difference");
      end
    end

    // Test 6: Logical equality with X returns X
    test_count++;
    begin
      static logic [3:0] a = 4'b10x1;
      static logic [3:0] b = 4'b1001;
      logic result;
      result = (a == b);
      // The x bit could make the operands equal or not, so the result is x
      // (11.4.5).
      if (result === 1'bx) begin
        $display("PASS: Equality with X returns unknown/x");
        pass_count++;
      end else begin
        $display("FAIL: Equality with X gave %b", result);
      end
    end

    // Test 7: Zero extension in comparison
    test_count++;
    begin
      static logic [7:0] a = 8'hFF;
      static logic [3:0] b = 4'hF;
      if (a != b) begin
        $display("PASS: 8'hFF != 4'hF (width mismatch)");
        pass_count++;
      end else begin
        $display("FAIL: Different widths should not equal");
      end
    end

    // Test 8: Sign extension comparison
    test_count++;
    begin
      static logic signed [7:0] a = -1;  // 8'hFF
      static logic signed [7:0] b = 8'hFF;
      if (a == b) begin
        $display("PASS: Signed -1 == 8'hFF");
        pass_count++;
      end else begin
        $display("FAIL: Signed comparison failed");
      end
    end

    // Test 9: Unsigned to signed comparison
    test_count++;
    begin
      static logic [7:0] a = 8'hFF;  // 255 unsigned
      static logic signed [7:0] b = -1;  // -1 signed (same bits)
      if (a === b) begin
        $display("PASS: Case equality ignores signedness (same bits)");
        pass_count++;
      end else begin
        $display("FAIL: Case equality should match bits");
      end
    end

    // Test 10: Reduction OR with all zeros
    test_count++;
    begin
      static logic [7:0] a = 8'h00;
      if (|a == 0) begin
        $display("PASS: Reduction OR of zeros = 0");
        pass_count++;
      end else begin
        $display("FAIL: Reduction OR should be 0");
      end
    end

    // Test 11: Reduction AND with all ones
    test_count++;
    begin
      static logic [7:0] a = 8'hFF;
      if (&a == 1) begin
        $display("PASS: Reduction AND of all ones = 1");
        pass_count++;
      end else begin
        $display("FAIL: Reduction AND should be 1");
      end
    end

    // Test 12: Reduction XOR (parity)
    test_count++;
    begin
      static logic [7:0] a = 8'b10101010;  // 4 ones = even parity
      if (^a == 0) begin
        $display("PASS: Reduction XOR even parity = 0");
        pass_count++;
      end else begin
        $display("FAIL: Reduction XOR should be 0 for even parity");
      end
    end

    // Summary
    $display("");
    $display("=== Value Operations Comprehensive Test Summary ===");
    $display("Tests: %0d, Passed: %0d", test_count, pass_count);
    if (pass_count == test_count) begin
      $display("PASS: All value operations tests passed");
    end else begin
      $display("FAIL: Some value operations tests failed");
    end

    $finish;
  end

endmodule
