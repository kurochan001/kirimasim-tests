/*
:name: test_real_arithmetic
:description: Real arithmetic and rounding conversion of real to int
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12.1 6.24.1 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_arithmetic.expected
*/
// Real arithmetic and conversion of real to int (rounds, 6.12.1)
module test_real_arithmetic;

  initial begin
    real a, b, c;
    real result;
    static int pass_count = 0;

    $display("=== Real Arithmetic Test ===");

    // Test 1: Basic addition
    a = 1.5;
    b = 2.3;
    result = a + b;
    if (result == 3.8) begin
      $display("[PASS] Addition: %f + %f = %f", a, b, result);
      pass_count++;
    end else begin
      $display("[FAIL] Addition: %f + %f = %f (expected 3.8)", a, b, result);
    end

    // Test 2: Multiplication
    a = 2.5;
    b = 3.0;
    result = a * b;
    if (result == 7.5) begin
      $display("[PASS] Multiplication: %f * %f = %f", a, b, result);
      pass_count++;
    end else begin
      $display("[FAIL] Multiplication: %f * %f = %f (expected 7.5)", a, b, result);
    end

    // Test 3: Division
    a = 10.0;
    b = 4.0;
    result = a / b;
    if (result == 2.5) begin
      $display("[PASS] Division: %f / %f = %f", a, b, result);
      pass_count++;
    end else begin
      $display("[FAIL] Division: %f / %f = %f (expected 2.5)", a, b, result);
    end

    // Test 4: Mixed operations
    a = 1.5;
    b = 2.0;
    c = 3.0;
    result = a + b * c;  // Should be 1.5 + 6.0 = 7.5
    if (result == 7.5) begin
      $display("[PASS] Mixed: %f + %f * %f = %f", a, b, c, result);
      pass_count++;
    end else begin
      $display("[FAIL] Mixed: %f + %f * %f = %f (expected 7.5)", a, b, c, result);
    end

    // Test 5: Real to int conversion
    a = 3.7;
    begin
      int int_val;
      int_val = int'(a);
      if (int_val == 4) begin
        $display("[PASS] Real to int: %f -> %0d", a, int_val);
        pass_count++;
      end else begin
        $display("[FAIL] Real to int: %f -> %0d (expected 4)", a, int_val);
      end
    end

    $display("\n=== Summary: %0d/5 tests passed ===", pass_count);

    $finish;
  end

endmodule
