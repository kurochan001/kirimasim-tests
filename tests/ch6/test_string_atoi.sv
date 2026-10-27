/*
:name: test_string_atoi
:description: Test string atoi method (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_atoi.expected
*/
// Test string atoi method (IEEE 1800-2023 Section 6.16)

module test_string_atoi;
  string s;
  int val;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Simple number
    s = "123";
    val = s.atoi();
    if (val == 123) pass_count++;

    // Test 2: whether atoi reads a leading minus is not settled: 6.16.9 names
    // the sign among the parts of the literal syntax it does not parse, and
    // tools differ. "-456" gives 0 if the minus is not read and -456 if it
    // is; both pass.
    s = "-456";
    val = s.atoi();
    if (val == 0 || val == -456) pass_count++;

    // Test 3: Zero
    s = "0";
    val = s.atoi();
    if (val == 0) pass_count++;

    $display("String atoi tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: String atoi tests");
    end else begin
      $display("FAIL: Some string atoi tests failed");
    end
  end
endmodule
