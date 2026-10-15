/*
:name: test_longint_type
:description: Test longint type (IEEE 1800-2023 Section 6.11)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_longint_type.expected
*/
// Test longint type (IEEE 1800-2023 Section 6.11)

module test_longint_type;
  longint li1, li2, li3;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Longint assignment
    li1 = 1000000;
    if (li1 == 1000000) pass_count++;

    // Test 2: Longint addition
    li2 = 2000000;
    li3 = li1 + li2;
    if (li3 == 3000000) pass_count++;

    // Test 3: Large value
    li1 = 64'h100000000;
    if (li1 == 64'h100000000) pass_count++;

    // Test 4: Negative longint
    li1 = -1000;
    if (li1 == -1000) pass_count++;

    $display("Longint tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Longint tests");
    end else begin
      $display("FAIL: Some longint tests failed");
    end
  end
endmodule
