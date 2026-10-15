/*
:name: test_string_atooct_2
:description: Test string atooct method (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_atooct_2.expected
*/
// Test string atooct method (IEEE 1800-2023 Section 6.16)

module test_string_atooct_2;
  string s;
  int val;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Simple octal
    s = "77";
    val = s.atooct();
    if (val == 63) pass_count++;

    // Test 2: Zero
    s = "0";
    val = s.atooct();
    if (val == 0) pass_count++;

    // Test 3: Longer octal
    s = "123";
    val = s.atooct();
    if (val == 83) pass_count++;

    $display("String atooct tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: String atooct tests");
    end else begin
      $display("FAIL: Some string atooct tests failed");
    end
  end
endmodule
