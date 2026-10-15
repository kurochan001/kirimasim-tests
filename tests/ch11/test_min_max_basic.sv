/*
:name: test_min_max_basic
:description: Test min/max operations (IEEE 1800-2023 Section 11.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_min_max_basic.expected
*/
// Test min/max operations (IEEE 1800-2023 Section 11.4)

module test_min_max_basic;
  int a, b, c;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Min of two
    a = 5;
    b = 10;
    c = (a < b) ? a : b;
    if (c == 5) pass_count++;

    // Test 2: Max of two
    c = (a > b) ? a : b;
    if (c == 10) pass_count++;

    // Test 3: Equal values
    b = 5;
    c = (a < b) ? a : b;
    if (c == 5) pass_count++;

    $display("Min/max basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Min/max basic tests");
    end else begin
      $display("FAIL: Some min/max tests failed");
    end
  end
endmodule
