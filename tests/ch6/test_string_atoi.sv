/*
:name: test_string_atoi
:description: Test string atoi method (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.9
:oracle: spec iverilog@13.0
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

    // Test 2: atoi does not parse a sign, so "-456" has no leading digits
    // and gives 0 (6.16.9)
    s = "-456";
    val = s.atoi();
    if (val == 0) pass_count++;

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
