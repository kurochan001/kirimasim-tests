/*
:name: test_power_op
:description: Test power operator (IEEE 1800-2023 Section 11.4.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_power_op.expected
*/
// Test power operator (IEEE 1800-2023 Section 11.4.3)

module test_power_op;
  int a, b;
  real r;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Integer power
    a = 2 ** 4;
    if (a == 16) pass_count++;

    // Test 2: Power of 0
    a = 5 ** 0;
    if (a == 1) pass_count++;

    // Test 3: Power of 1
    a = 7 ** 1;
    if (a == 7) pass_count++;

    // Test 4: Larger power
    a = 3 ** 3;
    if (a == 27) pass_count++;

    $display("Power op tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Power op tests");
    end else begin
      $display("FAIL: Some power op tests failed");
    end
  end
endmodule
