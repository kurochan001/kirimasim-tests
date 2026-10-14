/*
:name: test_system_functions_edge
:description: System Functions Edge Cases
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8 20.8.2 20.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_system_functions_edge.expected
*/
// IEEE 1800-2023 System Functions Edge Cases
// Sections: §20.9 (bit vector), §20.8 (math), §20.8.2 (trigonometric)
// PASS_CRITERIA: All $display("PASS:*") messages must appear

module test_system_functions_edge;

  initial begin
    static int pass_count = 0;
    static int total_tests = 25;

    // Test 1: $onehot(8'h01) = 1 (§20.9)
    begin
      static logic [7:0] val = 8'h01;
      if ($onehot(val) == 1) begin
        $display("PASS: Test 1 - $onehot(8'h01) = 1");
        pass_count++;
      end else $display("FAIL: Test 1 - $onehot(01) (got %0d)", $onehot(val));
    end

    // Test 2: $onehot(8'h00) = 0 (§20.9)
    begin
      static logic [7:0] val = 8'h00;
      if ($onehot(val) == 0) begin
        $display("PASS: Test 2 - $onehot(8'h00) = 0");
        pass_count++;
      end else $display("FAIL: Test 2 - $onehot(00) (got %0d)", $onehot(val));
    end

    // Test 3: $onehot(8'h03) = 0 (§20.9)
    begin
      static logic [7:0] val = 8'h03;
      if ($onehot(val) == 0) begin
        $display("PASS: Test 3 - $onehot(8'h03) = 0 (two bits set)");
        pass_count++;
      end else $display("FAIL: Test 3 - $onehot(03) (got %0d)", $onehot(val));
    end

    // Test 4: $onehot0(8'h00) = 1 (§20.9)
    begin
      static logic [7:0] val = 8'h00;
      if ($onehot0(val) == 1) begin
        $display("PASS: Test 4 - $onehot0(8'h00) = 1 (zero OK)");
        pass_count++;
      end else $display("FAIL: Test 4 - $onehot0(00) (got %0d)", $onehot0(val));
    end

    // Test 5: $onehot0(8'h01) = 1 (§20.9)
    begin
      static logic [7:0] val = 8'h01;
      if ($onehot0(val) == 1) begin
        $display("PASS: Test 5 - $onehot0(8'h01) = 1");
        pass_count++;
      end else $display("FAIL: Test 5 - $onehot0(01) (got %0d)", $onehot0(val));
    end

    // Test 6: $onehot0(8'h03) = 0 (§20.9)
    begin
      static logic [7:0] val = 8'h03;
      if ($onehot0(val) == 0) begin
        $display("PASS: Test 6 - $onehot0(8'h03) = 0 (two bits set)");
        pass_count++;
      end else $display("FAIL: Test 6 - $onehot0(03) (got %0d)", $onehot0(val));
    end

    // Test 7: $isunknown 0/1 = 0 (§20.9)
    begin
      static logic [7:0] val = 8'hFF;
      if ($isunknown(val) == 0) begin
        $display("PASS: Test 7 - $isunknown(known) = 0");
        pass_count++;
      end else $display("FAIL: Test 7 - $isunknown known (got %0d)", $isunknown(val));
    end

    // Test 8: $isunknown X = 1 (§20.9)
    begin
      static logic [7:0] val = 8'bxxxx_xxxx;
      if ($isunknown(val) == 1) begin
        $display("PASS: Test 8 - $isunknown(X) = 1");
        pass_count++;
      end else $display("FAIL: Test 8 - $isunknown X (got %0d)", $isunknown(val));
    end

    // Test 9: $isunknown Z = 1 (§20.9)
    begin
      static logic [7:0] val = 8'bzzzz_zzzz;
      if ($isunknown(val) == 1) begin
        $display("PASS: Test 9 - $isunknown(Z) = 1");
        pass_count++;
      end else $display("FAIL: Test 9 - $isunknown Z (got %0d)", $isunknown(val));
    end

    // Test 10: $countones(8'hFF) = 8 (§20.9)
    begin
      static logic [7:0] val = 8'hFF;
      if ($countones(val) == 8) begin
        $display("PASS: Test 10 - $countones(FF) = 8");
        pass_count++;
      end else $display("FAIL: Test 10 - $countones FF (got %0d)", $countones(val));
    end

    // Test 11: $countones(8'h00) = 0 (§20.9)
    begin
      static logic [7:0] val = 8'h00;
      if ($countones(val) == 0) begin
        $display("PASS: Test 11 - $countones(00) = 0");
        pass_count++;
      end else $display("FAIL: Test 11 - $countones 00 (got %0d)", $countones(val));
    end

    // Test 12: $countones(16'hAAAA) (§20.9)
    begin
      static logic [15:0] val = 16'hAAAA;
      if ($countones(val) == 8) begin
        $display("PASS: Test 12 - $countones(AAAA) = 8");
        pass_count++;
      end else $display("FAIL: Test 12 - $countones AAAA (got %0d)", $countones(val));
    end

    // Test 13: $countbits for 1s (§20.9)
    begin
      static logic [7:0] val = 8'b10101010;
      static int cnt;
      // Assigned here so the result does not depend on the order of static initializers.
      cnt = $countbits(val, 1'b1);
      if (cnt == 4) begin
        $display("PASS: Test 13 - $countbits(AA, 1) = 4");
        pass_count++;
      end else $display("FAIL: Test 13 - $countbits 1 (got %0d)", cnt);
    end

    // Test 14: $countbits for 0s (§20.9)
    begin
      static logic [7:0] val = 8'b10101010;
      static int cnt;
      // Assigned here so the result does not depend on the order of static initializers.
      cnt = $countbits(val, 1'b0);
      if (cnt == 4) begin
        $display("PASS: Test 14 - $countbits(AA, 0) = 4");
        pass_count++;
      end else $display("FAIL: Test 14 - $countbits 0 (got %0d)", cnt);
    end

    // Test 15: $sqrt(4.0) = 2.0 (§20.8)
    begin
      static real result = $sqrt(4.0);
      if (result > 1.99 && result < 2.01) begin
        $display("PASS: Test 15 - $sqrt(4.0) = 2.0");
        pass_count++;
      end else $display("FAIL: Test 15 - $sqrt (got %f)", result);
    end

    // Test 16: $sqrt(-1.0) = NaN (§20.8)
    begin
      static real result = $sqrt(-1.0);
      // NaN != NaN
      if (result != result) begin
        $display("PASS: Test 16 - $sqrt(-1.0) = NaN");
        pass_count++;
      end else $display("FAIL: Test 16 - $sqrt neg (got %f)", result);
    end

    // Test 17: $ln(1.0) = 0.0 (§20.8)
    begin
      static real result = $ln(1.0);
      if (result > -0.01 && result < 0.01) begin
        $display("PASS: Test 17 - $ln(1.0) = 0.0");
        pass_count++;
      end else $display("FAIL: Test 17 - $ln(1) (got %f)", result);
    end

    // Test 18: $exp(0.0) = 1.0 (§20.8)
    begin
      static real result = $exp(0.0);
      if (result > 0.99 && result < 1.01) begin
        $display("PASS: Test 18 - $exp(0.0) = 1.0");
        pass_count++;
      end else $display("FAIL: Test 18 - $exp(0) (got %f)", result);
    end

    // Test 19: $ln(0.0) = -inf (§20.8)
    begin
      static real result = $ln(0.0);
      if (result < -1.0e300) begin
        $display("PASS: Test 19 - $ln(0.0) = -inf");
        pass_count++;
      end else $display("FAIL: Test 19 - $ln(0) (got %f)", result);
    end

    // Test 20: $floor(3.8) = 3.0 (§20.8)
    begin
      static real result = $floor(3.8);
      if (result > 2.99 && result < 3.01) begin
        $display("PASS: Test 20 - $floor(3.8) = 3.0");
        pass_count++;
      end else $display("FAIL: Test 20 - $floor (got %f)", result);
    end

    // Test 21: $ceil(3.2) = 4.0 (§20.8)
    begin
      static real result = $ceil(3.2);
      if (result > 3.99 && result < 4.01) begin
        $display("PASS: Test 21 - $ceil(3.2) = 4.0");
        pass_count++;
      end else $display("FAIL: Test 21 - $ceil (got %f)", result);
    end

    // Test 22: $sin(0.0) = 0.0 (§20.8)
    begin
      static real result = $sin(0.0);
      if (result > -0.01 && result < 0.01) begin
        $display("PASS: Test 22 - $sin(0.0) = 0.0");
        pass_count++;
      end else $display("FAIL: Test 22 - $sin(0) (got %f)", result);
    end

    // Test 23: $atan2(1.0, 1.0) = pi/4 (§20.8)
    begin
      static real result = $atan2(1.0, 1.0);
      static real expected = 0.7853981633974483;
      if (result > expected - 0.001 && result < expected + 0.001) begin
        $display("PASS: Test 23 - $atan2(1,1) = pi/4");
        pass_count++;
      end else $display("FAIL: Test 23 - $atan2 (got %f)", result);
    end

    // Test 24: $hypot(3.0, 4.0) = 5.0 (§20.8)
    begin
      static real result = $hypot(3.0, 4.0);
      if (result > 4.99 && result < 5.01) begin
        $display("PASS: Test 24 - $hypot(3,4) = 5.0");
        pass_count++;
      end else $display("FAIL: Test 24 - $hypot (got %f)", result);
    end

    // Test 25: $pow(2.0, 10.0) = 1024.0 (§20.8)
    begin
      static real result = $pow(2.0, 10.0);
      if (result > 1023.9 && result < 1024.1) begin
        $display("PASS: Test 25 - $pow(2,10) = 1024.0");
        pass_count++;
      end else $display("FAIL: Test 25 - $pow (got %f)", result);
    end

    $display("\n=== System Functions Edge Cases Summary ===");
    $display("Tests passed: %0d/%0d", pass_count, total_tests);
    if (pass_count == total_tests) $display("ALL TESTS PASSED");
    else $display("SOME TESTS FAILED");
    $finish;
  end
endmodule
