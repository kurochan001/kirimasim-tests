/*
:name: test_immediate_simple
:description: Immediate assertions with fail action blocks (IEEE 1800-2023 Section 16.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_immediate_simple.expected
*/
// Immediate assertions with fail action blocks (IEEE 1800-2023 Section 16.3)
module test_immediate_simple;
  int a, b, c;
  int failure_count = 0;

  initial begin
    $display("=== Immediate Assertion Test ===");

    // Test 1: Basic assertion
    a = 5;
    b = 10;
    assert (a < b) else begin
      $display("Assertion failed: a < b");
      failure_count++;
    end

    // Test 2: Complex expression
    c = 15;
    assert ((a + b) == c) else begin
      $display("Assertion failed: a + b == c");
      failure_count++;
    end

    // Test 3: Arithmetic assertion
    assert ((a * 2) == b) else begin
      $display("Assertion failed: a * 2 == b");
      failure_count++;
    end

    // Test 4: Logical combination
    assert ((a > 0) && (b > 0) && (c > 0)) else begin
      $display("Assertion failed: all positive");
      failure_count++;
    end

    // Test 5: Deliberate failure
    assert (a > b) else begin
      $display("Expected failure: a > b");
      failure_count++;
    end

    // Summary
    if (failure_count == 1) begin
      $display("PASS: 4/5 assertions passed (1 expected failure)");
    end else begin
      $display("FAIL: %0d unexpected failures", failure_count - 1);
    end

    $finish;
  end
endmodule
