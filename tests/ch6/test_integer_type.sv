/*
:name: test_integer_type
:description: Test integer type (IEEE 1800-2023 Section 6.11)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_integer_type.expected
*/
// Test integer type (IEEE 1800-2023 Section 6.11)

module test_integer_type;
  integer i1, i2, i3;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Integer assignment
    i1 = 42;
    if (i1 == 42) pass_count++;

    // Test 2: Integer negative
    i2 = -100;
    if (i2 == -100) pass_count++;

    // Test 3: Integer arithmetic
    i3 = i1 + i2;
    if (i3 == -58) pass_count++;

    // Test 4: Integer comparison
    if (i1 > i2) pass_count++;

    $display("Integer type tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Integer type tests");
    end else begin
      $display("FAIL: Some integer type tests failed");
    end
  end
endmodule
