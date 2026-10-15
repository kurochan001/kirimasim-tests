/*
:name: test_value_ops_comparison
:description: Test for comparison value operations (IEEE 1800-2023 §11.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_value_ops_comparison.expected
*/
// Test for comparison value operations (IEEE 1800-2023 §11.4)

module test_value_ops_comparison;
  int a, b;
  logic [7:0] x, y;
  logic result;
  int passed;

  initial begin
    passed = 0;

    // Test 1: Integer equality
    $display("Test 1: Integer equality");
    a = 42;
    b = 42;
    if (a == b) begin
      $display("  PASS: %0d == %0d", a, b);
      passed++;
    end else begin
      $display("  FAIL: equality test failed");
    end

    // Test 2: Integer inequality
    $display("Test 2: Integer inequality");
    b = 43;
    if (a != b) begin
      $display("  PASS: %0d != %0d", a, b);
      passed++;
    end else begin
      $display("  FAIL: inequality test failed");
    end

    // Test 3: Less than
    $display("Test 3: Less than");
    if (a < b) begin
      $display("  PASS: %0d < %0d", a, b);
      passed++;
    end else begin
      $display("  FAIL: less than test failed");
    end

    // Test 4: Greater than
    $display("Test 4: Greater than");
    if (b > a) begin
      $display("  PASS: %0d > %0d", b, a);
      passed++;
    end else begin
      $display("  FAIL: greater than test failed");
    end

    // Test 5: Less or equal
    $display("Test 5: Less or equal");
    a = 42;
    b = 42;
    if (a <= b) begin
      $display("  PASS: %0d <= %0d", a, b);
      passed++;
    end else begin
      $display("  FAIL: less or equal test failed");
    end

    // Test 6: Greater or equal
    $display("Test 6: Greater or equal");
    if (a >= b) begin
      $display("  PASS: %0d >= %0d", a, b);
      passed++;
    end else begin
      $display("  FAIL: greater or equal test failed");
    end

    // Test 7: Case equality with X
    $display("Test 7: Case equality");
    x = 8'b1010_xxxx;
    y = 8'b1010_xxxx;
    if (x === y) begin
      $display("  PASS: case equality with x");
      passed++;
    end else begin
      $display("  FAIL: case equality result");
    end

    // Test 8: Wildcard equality
    $display("Test 8: Wildcard equality");
    x = 8'b1010_0000;
    y = 8'b1010_xxxx;
    if (x ==? y) begin
      $display("  PASS: wildcard equality");
      passed++;
    end else begin
      $display("  FAIL: wildcard equality result");
    end

    if (passed == 8) begin
      $display("TEST PASSED: %0d/8 tests passed", passed);
    end else begin
      $display("TEST FAILED: %0d/8 tests passed", passed);
    end
    $finish;
  end
endmodule
