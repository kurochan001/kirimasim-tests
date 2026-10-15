/*
:name: test_string_atohex_2
:description: Test string atohex method (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_atohex_2.expected
*/
// Test string atohex method (IEEE 1800-2023 Section 6.16)

module test_string_atohex;
  string s;
  int val;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Simple hex
    s = "FF";
    val = s.atohex();
    if (val == 255) pass_count++;

    // Test 2: Lower case hex
    s = "ab";
    val = s.atohex();
    if (val == 171) pass_count++;

    // Test 3: Mixed case
    s = "1A2B";
    val = s.atohex();
    if (val == 6699) pass_count++;

    $display("String atohex tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: String atohex tests");
    end else begin
      $display("FAIL: Some string atohex tests failed");
    end
  end
endmodule
