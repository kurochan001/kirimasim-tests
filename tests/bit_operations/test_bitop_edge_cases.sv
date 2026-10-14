/*
:name: test_bitop_edge_cases
:description: Test for bit operation edge cases (IEEE 1800-2023 §20.9)
:tags: bit_operations
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bitop_edge_cases.expected
*/
// Test for bit operation edge cases (IEEE 1800-2023 §20.9)
// Tests $onehot, $onehot0, $isunknown, $countones edge cases

module test_bitop_edge_cases;

  int pass_count = 0;
  int test_count = 0;

  initial begin
    // Test 1: $onehot with MSB set (bit 31)
    test_count++;
    begin
      static logic [31:0] val = 32'h80000000;
      if ($onehot(val) == 1) begin
        $display("PASS: $onehot(32'h80000000) = 1 (MSB only)");
        pass_count++;
      end else begin
        $display("FAIL: $onehot(32'h80000000) expected 1, got %0d", $onehot(val));
      end
    end

    // Test 2: $onehot with LSB set (bit 0)
    test_count++;
    begin
      static logic [31:0] val = 32'h00000001;
      if ($onehot(val) == 1) begin
        $display("PASS: $onehot(32'h00000001) = 1 (LSB only)");
        pass_count++;
      end else begin
        $display("FAIL: $onehot(32'h00000001) expected 1, got %0d", $onehot(val));
      end
    end

    // Test 3: $onehot counts only 1 bits, so one 1 bit and one X bit gives 1
    test_count++;
    begin
      static logic [7:0] val = 8'b0001x000;
      if ($onehot(val) == 1) begin
        $display("PASS: $onehot with X bit = 1");
        pass_count++;
      end else begin
        $display("FAIL: $onehot with X bit expected 1, got %0d", $onehot(val));
      end
    end

    // Test 4: $onehot0 with all X: no 1 bits, so the result is 1
    test_count++;
    begin
      static logic [7:0] val = 8'bxxxxxxxx;
      if ($onehot0(val) == 1) begin
        $display("PASS: $onehot0 with all X = 1");
        pass_count++;
      end else begin
        $display("FAIL: $onehot0 with all X expected 1, got %0d", $onehot0(val));
      end
    end

    // Test 5: $isunknown with single X at LSB
    test_count++;
    begin
      static logic [7:0] val = 8'b1111111x;
      if ($isunknown(val) == 1) begin
        $display("PASS: $isunknown with LSB X = 1");
        pass_count++;
      end else begin
        $display("FAIL: $isunknown with LSB X expected 1, got %0d", $isunknown(val));
      end
    end

    // Test 6: $isunknown with single X at MSB
    test_count++;
    begin
      static logic [7:0] val = 8'bx1111111;
      if ($isunknown(val) == 1) begin
        $display("PASS: $isunknown with MSB X = 1");
        pass_count++;
      end else begin
        $display("FAIL: $isunknown with MSB X expected 1, got %0d", $isunknown(val));
      end
    end

    // Test 7: $countones with 64-bit value
    test_count++;
    begin
      static logic [63:0] val = 64'hFFFFFFFF00000000;
      if ($countones(val) == 32) begin
        $display("PASS: $countones(64'hFFFFFFFF00000000) = 32");
        pass_count++;
      end else begin
        $display("FAIL: $countones expected 32, got %0d", $countones(val));
      end
    end

    // Test 8: $countones with alternating bits
    test_count++;
    begin
      static logic [15:0] val = 16'hAAAA;  // 1010_1010_1010_1010
      if ($countones(val) == 8) begin
        $display("PASS: $countones(16'hAAAA) = 8");
        pass_count++;
      end else begin
        $display("FAIL: $countones expected 8, got %0d", $countones(val));
      end
    end

    // Test 9: $onehot with power of 2
    test_count++;
    begin
      static logic [15:0] val = 16'h0100;  // bit 8 set
      if ($onehot(val) == 1) begin
        $display("PASS: $onehot(16'h0100) = 1 (power of 2)");
        pass_count++;
      end else begin
        $display("FAIL: $onehot power of 2 expected 1, got %0d", $onehot(val));
      end
    end

    // Test 10: $onehot0 with Z bits: no 1 bits, so the result is 1
    test_count++;
    begin
      static logic [7:0] val = 8'b0000zzzz;
      if ($onehot0(val) == 1) begin
        $display("PASS: $onehot0 with Z bits = 1");
        pass_count++;
      end else begin
        $display("FAIL: $onehot0 with Z bits expected 1, got %0d", $onehot0(val));
      end
    end

    // Test 11: $isunknown with mixed X and Z
    test_count++;
    begin
      static logic [7:0] val = 8'b10xz10xz;
      if ($isunknown(val) == 1) begin
        $display("PASS: $isunknown with mixed X and Z = 1");
        pass_count++;
      end else begin
        $display("FAIL: $isunknown with mixed X and Z expected 1, got %0d", $isunknown(val));
      end
    end

    // Test 12: $countones with single 1 in 32-bit vector
    test_count++;
    begin
      static logic [31:0] val = 32'h0;
      val[16] = 1'b1;
      if ($countones(val) == 1) begin
        $display("PASS: $countones 32-bit vector single bit = 1");
        pass_count++;
      end else begin
        $display("FAIL: $countones 32-bit expected 1, got %0d", $countones(val));
      end
    end

    // Summary
    $display("");
    $display("=== Bit Operation Edge Cases Test Summary ===");
    $display("Tests: %0d, Passed: %0d", test_count, pass_count);
    if (pass_count == test_count) begin
      $display("PASS: All bit operation edge case tests passed");
    end else begin
      $display("FAIL: Some bit operation edge case tests failed");
    end

    $finish;
  end

endmodule
