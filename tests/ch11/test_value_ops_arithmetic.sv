/*
:name: test_value_ops_arithmetic
:description: Test for arithmetic value operations (IEEE 1800-2023 §11.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_value_ops_arithmetic.expected
*/
// Test for arithmetic value operations (IEEE 1800-2023 §11.4)

module test_value_ops_arithmetic;
  int a, b, c;
  real r1, r2, r3;
  logic [31:0] u1, u2;
  int passed;

  initial begin
    passed = 0;

    // Test 1: Integer addition
    $display("Test 1: Integer addition");
    a = 100;
    b = 200;
    c = a + b;
    if (c == 300) begin
      $display("  PASS: %0d + %0d = %0d", a, b, c);
      passed++;
    end else begin
      $display("  FAIL: expected 300, got %0d", c);
    end

    // Test 2: Integer subtraction
    $display("Test 2: Integer subtraction");
    c = b - a;
    if (c == 100) begin
      $display("  PASS: %0d - %0d = %0d", b, a, c);
      passed++;
    end else begin
      $display("  FAIL: expected 100, got %0d", c);
    end

    // Test 3: Integer multiplication
    $display("Test 3: Integer multiplication");
    a = 12;
    b = 13;
    c = a * b;
    if (c == 156) begin
      $display("  PASS: %0d * %0d = %0d", a, b, c);
      passed++;
    end else begin
      $display("  FAIL: expected 156, got %0d", c);
    end

    // Test 4: Integer division
    $display("Test 4: Integer division");
    a = 100;
    b = 7;
    c = a / b;
    if (c == 14) begin
      $display("  PASS: %0d / %0d = %0d", a, b, c);
      passed++;
    end else begin
      $display("  FAIL: expected 14, got %0d", c);
    end

    // Test 5: Integer modulo
    $display("Test 5: Integer modulo");
    c = a % b;
    if (c == 2) begin
      $display("  PASS: %0d %% %0d = %0d", a, b, c);
      passed++;
    end else begin
      $display("  FAIL: expected 2, got %0d", c);
    end

    // Test 6: Real arithmetic
    $display("Test 6: Real arithmetic");
    r1 = 3.5;
    r2 = 2.0;
    r3 = r1 + r2;
    $display("  %f + %f = %f", r1, r2, r3);
    r3 = r1 * r2;
    $display("  %f * %f = %f", r1, r2, r3);
    r3 = r1 / r2;
    $display("  %f / %f = %f", r1, r2, r3);
    passed++;

    // Test 7: Negative numbers
    $display("Test 7: Negative numbers");
    a = -10;
    b = 3;
    c = a * b;
    if (c == -30) begin
      $display("  PASS: %0d * %0d = %0d", a, b, c);
      passed++;
    end else begin
      $display("  FAIL: expected -30, got %0d", c);
    end

    // Test 8: Power operator
    $display("Test 8: Power operator");
    a = 2;
    b = 10;
    c = a ** b;
    if (c == 1024) begin
      $display("  PASS: %0d ** %0d = %0d", a, b, c);
      passed++;
    end else begin
      $display("  FAIL: %0d ** %0d = %0d", a, b, c);
    end

    if (passed == 8) begin
      $display("TEST PASSED: %0d/8 tests passed", passed);
    end else begin
      $display("TEST FAILED: %0d/8 tests passed", passed);
    end
    $finish;
  end
endmodule
