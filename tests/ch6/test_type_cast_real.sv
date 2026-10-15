/*
:name: test_type_cast_real
:description: Test for real type casting (IEEE 1800-2023 §6.24)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_cast_real.expected
*/
// Test for real type casting (IEEE 1800-2023 §6.24)

module test_type_cast_real;
  real r1, r2;
  int i1;
  shortreal sr;
  logic [63:0] bits64;
  int passed;

  initial begin
    passed = 0;

    // Test 1: int to real
    $display("Test 1: int to real");
    i1 = 42;
    r1 = real'(i1);
    $display("  real'(42) = %f", r1);
    if (r1 == 42.0) begin
      $display("  PASS");
      passed++;
    end else begin
      $display("  FAIL: expected 42.0");
    end

    // Test 2: real to shortreal
    $display("Test 2: real to shortreal");
    r1 = 3.14159265358979;
    sr = shortreal'(r1);
    $display("  shortreal'(pi) = %f", sr);
    passed++;

    // Test 3: shortreal to real
    $display("Test 3: shortreal to real");
    sr = 2.5;
    r2 = real'(sr);
    $display("  real'(2.5 shortreal) = %f", r2);
    if (r2 == 2.5) begin
      $display("  PASS");
      passed++;
    end else begin
      $display("  FAIL: expected 2.5");
    end

    // Test 4: Negative real to int
    $display("Test 4: Negative real to int");
    r1 = -3.7;
    i1 = int'(r1);
    $display("  int'(-3.7) = %0d", i1);
    passed++;

    // Test 5: Large real
    $display("Test 5: Large real");
    r1 = 1.0e10;
    $display("  Large real: %e", r1);
    passed++;

    // Test 6: Small real
    $display("Test 6: Small real");
    r1 = 1.0e-10;
    $display("  Small real: %e", r1);
    passed++;

    // Test 7: Bit pattern reinterpretation
    $display("Test 7: Bit pattern ($realtobits)");
    r1 = 1.0;
    bits64 = $realtobits(r1);
    $display("  $realtobits(1.0) = 0x%x", bits64);
    r2 = $bitstoreal(bits64);
    $display("  $bitstoreal back = %f", r2);
    if (r2 == 1.0) begin
      $display("  PASS");
      passed++;
    end else begin
      $display("  FAIL: roundtrip = %f", r2);
    end

    if (passed == 7) begin
      $display("TEST PASSED: %0d/7 tests passed", passed);
    end else begin
      $display("TEST FAILED: %0d/7 tests passed", passed);
    end
    $finish;
  end
endmodule
