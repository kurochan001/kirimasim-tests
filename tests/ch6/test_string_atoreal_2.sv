/*
:name: test_string_atoreal_2
:description: Test string atoreal method (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_atoreal_2.expected
*/
// Test string atoreal method (IEEE 1800-2023 Section 6.16)

module test_string_atoreal;
  string s;
  real val;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Simple real
    s = "3.14";
    val = s.atoreal();
    if (val > 3.1 && val < 3.2) pass_count++;

    // Test 2: Integer as real
    s = "42";
    val = s.atoreal();
    if (val == 42.0) pass_count++;

    // Test 3: Negative real
    s = "-1.5";
    val = s.atoreal();
    if (val < -1.4 && val > -1.6) pass_count++;

    $display("String atoreal tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: String atoreal tests");
    end else begin
      $display("FAIL: Some string atoreal tests failed");
    end
  end
endmodule
