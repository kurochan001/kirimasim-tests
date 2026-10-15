/*
:name: test_string_atobin_2
:description: Test string atobin method (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_atobin_2.expected
*/
// Test string atobin method (IEEE 1800-2023 Section 6.16)

module test_string_atobin_2;
  string s;
  int val;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Simple binary
    s = "1010";
    val = s.atobin();
    if (val == 10) pass_count++;

    // Test 2: All ones
    s = "1111";
    val = s.atobin();
    if (val == 15) pass_count++;

    // Test 3: Longer binary
    s = "11001100";
    val = s.atobin();
    if (val == 204) pass_count++;

    $display("String atobin tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: String atobin tests");
    end else begin
      $display("FAIL: Some string atobin tests failed");
    end
  end
endmodule
