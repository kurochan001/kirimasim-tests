/*
:name: test_shortint_type
:description: Test shortint type (IEEE 1800-2023 Section 6.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shortint_type.expected
*/
// Test shortint type (IEEE 1800-2023 Section 6.4)

module test_shortint_type;
  shortint si1, si2, si3;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Shortint assignment
    si1 = 100;
    if (si1 == 100) pass_count++;

    // Test 2: Shortint addition
    si2 = 200;
    si3 = si1 + si2;
    if (si3 == 300) pass_count++;

    // Test 3: Shortint negative
    si1 = -50;
    if (si1 == -50) pass_count++;

    // Test 4: Shortint max value
    si1 = 32767;
    if (si1 == 32767) pass_count++;

    $display("Shortint tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Shortint tests");
    end else begin
      $display("FAIL: Some shortint tests failed");
    end
  end
endmodule
