/*
:name: test_countbits_detailed
:description: Test for $countbits detailed (IEEE 1800-2023 §20.9)
:tags: bit_operations
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_countbits_detailed.expected
*/
// Test for $countbits detailed (IEEE 1800-2023 §20.9)
// Tests $countbits with various bit values and patterns

module test_countbits_detailed;

  int pass_count = 0;
  int test_count = 0;

  initial begin
    // Test 1: Count zeros in all-ones vector
    test_count++;
    begin
      static logic [7:0] val = 8'b11111111;
      static int count = $countbits(val, 1'b0);
      if (count == 0) begin
        $display("PASS: $countbits(8'hFF, 0) = 0 zeros");
        pass_count++;
      end else begin
        $display("FAIL: Expected 0 zeros, got %0d", count);
      end
    end

    // Test 2: Count ones in all-ones vector
    test_count++;
    begin
      static logic [7:0] val = 8'b11111111;
      static int count = $countbits(val, 1'b1);
      if (count == 8) begin
        $display("PASS: $countbits(8'hFF, 1) = 8 ones");
        pass_count++;
      end else begin
        $display("FAIL: Expected 8 ones, got %0d", count);
      end
    end

    // Test 3: Count zeros in all-zeros vector
    test_count++;
    begin
      static logic [7:0] val = 8'b00000000;
      static int count = $countbits(val, 1'b0);
      if (count == 8) begin
        $display("PASS: $countbits(8'h00, 0) = 8 zeros");
        pass_count++;
      end else begin
        $display("FAIL: Expected 8 zeros, got %0d", count);
      end
    end

    // Test 4: Count ones in all-zeros vector
    test_count++;
    begin
      static logic [7:0] val = 8'b00000000;
      static int count = $countbits(val, 1'b1);
      if (count == 0) begin
        $display("PASS: $countbits(8'h00, 1) = 0 ones");
        pass_count++;
      end else begin
        $display("FAIL: Expected 0 ones, got %0d", count);
      end
    end

    // Test 5: Count ones in alternating pattern
    test_count++;
    begin
      static logic [7:0] val = 8'b10101010;
      static int count = $countbits(val, 1'b1);
      if (count == 4) begin
        $display("PASS: $countbits(8'hAA, 1) = 4 ones");
        pass_count++;
      end else begin
        $display("FAIL: Expected 4 ones, got %0d", count);
      end
    end

    // Test 6: Count zeros in alternating pattern
    test_count++;
    begin
      static logic [7:0] val = 8'b10101010;
      static int count = $countbits(val, 1'b0);
      if (count == 4) begin
        $display("PASS: $countbits(8'hAA, 0) = 4 zeros");
        pass_count++;
      end else begin
        $display("FAIL: Expected 4 zeros, got %0d", count);
      end
    end

    // Test 7: Count in 16-bit vector
    test_count++;
    begin
      static logic [15:0] val = 16'hF0F0;  // 8 ones, 8 zeros
      static int count = $countbits(val, 1'b1);
      if (count == 8) begin
        $display("PASS: $countbits(16'hF0F0, 1) = 8 ones");
        pass_count++;
      end else begin
        $display("FAIL: Expected 8 ones, got %0d", count);
      end
    end

    // Test 8: Count in 32-bit vector
    test_count++;
    begin
      static logic [31:0] val = 32'hFFFF0000;  // 16 ones, 16 zeros
      static int count = $countbits(val, 1'b1);
      if (count == 16) begin
        $display("PASS: $countbits(32'hFFFF0000, 1) = 16 ones");
        pass_count++;
      end else begin
        $display("FAIL: Expected 16 ones, got %0d", count);
      end
    end

    // Test 9: Count zeros in 32-bit vector
    test_count++;
    begin
      static logic [31:0] val = 32'hFFFF0000;
      static int count = $countbits(val, 1'b0);
      if (count == 16) begin
        $display("PASS: $countbits(32'hFFFF0000, 0) = 16 zeros");
        pass_count++;
      end else begin
        $display("FAIL: Expected 16 zeros, got %0d", count);
      end
    end

    // Test 10: Single bit set
    test_count++;
    begin
      static logic [31:0] val = 32'h00010000;  // bit 16 set
      static int ones = $countbits(val, 1'b1);
      static int zeros = $countbits(val, 1'b0);
      if (ones == 1 && zeros == 31) begin
        $display("PASS: $countbits single bit: 1 one, 31 zeros");
        pass_count++;
      end else begin
        $display("FAIL: Expected 1 one and 31 zeros, got %0d ones, %0d zeros", ones, zeros);
      end
    end

    // Test 11: Consistency check (ones + zeros = width)
    test_count++;
    begin
      static logic [15:0] val = 16'h1234;
      static int ones = $countbits(val, 1'b1);
      static int zeros = $countbits(val, 1'b0);
      if (ones + zeros == 16) begin
        $display("PASS: ones(%0d) + zeros(%0d) = 16", ones, zeros);
        pass_count++;
      end else begin
        $display("FAIL: ones + zeros should equal 16, got %0d", ones + zeros);
      end
    end

    // Test 12: Using $countones equivalence
    test_count++;
    begin
      static logic [7:0] val = 8'b11010110;  // 5 ones
      static int countbits_result = $countbits(val, 1'b1);
      static int countones_result = $countones(val);
      if (countbits_result == countones_result) begin
        $display("PASS: $countbits(,1) = $countones = %0d", countones_result);
        pass_count++;
      end else begin
        $display("FAIL: $countbits=%0d != $countones=%0d", countbits_result, countones_result);
      end
    end

    // Summary
    $display("");
    $display("=== Countbits Detailed Test Summary ===");
    $display("Tests: %0d, Passed: %0d", test_count, pass_count);
    if (pass_count == test_count) begin
      $display("PASS: All countbits tests passed");
    end else begin
      $display("FAIL: Some countbits tests failed");
    end

    $finish;
  end

endmodule
