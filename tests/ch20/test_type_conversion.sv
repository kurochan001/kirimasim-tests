/*
:name: test_type_conversion
:description: Test for type conversion functions (IEEE 1800-2023 §20.8)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_conversion.expected
*/
// Test for type conversion functions (IEEE 1800-2023 §20.5)
// Tests $itor, $rtoi, $realtobits, $bitstoreal, $shortrealtobits, $bitstoshortreal

module test_type_conversion;

  int pass_count = 0;
  int test_count = 0;
  real r;
  int i;
  logic [63:0] bits64;
  logic [31:0] bits32;
  real tolerance = 0.0001;

  // Helper function to check approximate equality
  function automatic bit approx_eq(real a, real b, real tol);
    real diff = a - b;
    if (diff < 0) diff = -diff;
    return diff < tol;
  endfunction

  initial begin
    // Test 1: $itor converts integer to real
    test_count++;
    r = $itor(42);
    if (approx_eq(r, 42.0, tolerance)) begin
      $display("PASS: $itor(42) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $itor(42) expected 42.0, got %f", r);
    end

    // Test 2: $itor with negative integer
    test_count++;
    r = $itor(-100);
    if (approx_eq(r, -100.0, tolerance)) begin
      $display("PASS: $itor(-100) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $itor(-100) expected -100.0, got %f", r);
    end

    // Test 3: $rtoi converts real to integer (truncation toward zero per IEEE 1800-2023)
    test_count++;
    i = $rtoi(3.7);
    if (i == 3) begin  // $rtoi truncates toward zero (20.5)
      $display("PASS: $rtoi(3.7) = %0d", i);
      pass_count++;
    end else begin
      $display("FAIL: $rtoi(3.7) expected 3, got %0d", i);
    end

    // Test 4: $rtoi with negative real (truncation toward zero)
    test_count++;
    i = $rtoi(-2.8);
    if (i == -2) begin
      $display("PASS: $rtoi(-2.8) = %0d", i);
      pass_count++;
    end else begin
      $display("FAIL: $rtoi(-2.8) expected -2, got %0d", i);
    end

    // Test 5: $rtoi truncates 2.5 as well
    test_count++;
    i = $rtoi(2.5);
    if (i == 2) begin
      $display("PASS: $rtoi(2.5) = %0d", i);
      pass_count++;
    end else begin
      $display("FAIL: $rtoi(2.5) expected 2, got %0d", i);
    end

    // Test 6: $realtobits and $bitstoreal roundtrip
    test_count++;
    begin
      static real orig = 3.14159;
      bits64 = $realtobits(orig);
      r = $bitstoreal(bits64);
      if (approx_eq(r, orig, tolerance)) begin
        $display("PASS: $bitstoreal($realtobits(3.14159)) = %f", r);
        pass_count++;
      end else begin
        $display("FAIL: roundtrip expected %f, got %f", orig, r);
      end
    end

    // Test 7: $realtobits for 0.0
    test_count++;
    bits64 = $realtobits(0.0);
    if (bits64 == 64'h0000000000000000) begin
      $display("PASS: $realtobits(0.0) = 0x%016X", bits64);
      pass_count++;
    end else begin
      $display("FAIL: $realtobits(0.0) = 0x%016X", bits64);
    end

    // Test 8: $realtobits for 1.0
    test_count++;
    bits64 = $realtobits(1.0);
    if (bits64 == 64'h3FF0000000000000) begin
      $display("PASS: $realtobits(1.0) = 0x%016X", bits64);
      pass_count++;
    end else begin
      $display("FAIL: $realtobits(1.0) expected 0x3FF0000000000000, got 0x%016X", bits64);
    end

    // Test 9: $shortrealtobits and $bitstoshortreal roundtrip
    test_count++;
    begin
      static real orig = 2.5;
      bits32 = $shortrealtobits(orig);
      r = $bitstoshortreal(bits32);
      if (approx_eq(r, orig, 0.001)) begin
        $display("PASS: $bitstoshortreal($shortrealtobits(2.5)) = %f", r);
        pass_count++;
      end else begin
        $display("FAIL: shortreal roundtrip expected %f, got %f", orig, r);
      end
    end

    // Test 10: $shortrealtobits for 1.0
    test_count++;
    bits32 = $shortrealtobits(1.0);
    if (bits32 == 32'h3F800000) begin
      $display("PASS: $shortrealtobits(1.0) = 0x%08X", bits32);
      pass_count++;
    end else begin
      $display("FAIL: $shortrealtobits(1.0) expected 0x3F800000, got 0x%08X", bits32);
    end

    // Test 11: $itor with zero
    test_count++;
    r = $itor(0);
    if (approx_eq(r, 0.0, tolerance)) begin
      $display("PASS: $itor(0) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $itor(0) expected 0.0, got %f", r);
    end

    // Test 12: $rtoi with small positive value
    test_count++;
    i = $rtoi(0.4);
    if (i == 0) begin
      $display("PASS: $rtoi(0.4) = %0d", i);
      pass_count++;
    end else begin
      $display("FAIL: $rtoi(0.4) expected 0, got %0d", i);
    end

    // Summary
    $display("");
    $display("=== Type Conversion Functions Test Summary ===");
    $display("Tests: %0d, Passed: %0d", test_count, pass_count);
    if (pass_count == test_count) begin
      $display("PASS: All type conversion function tests passed");
    end else begin
      $display("FAIL: Some type conversion function tests failed");
    end

    $finish;
  end

endmodule
