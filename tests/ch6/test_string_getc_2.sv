/*
:name: test_string_getc_2
:description: Test string getc (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_getc_2.expected
*/
// Test string getc (IEEE 1800-2023 Section 6.16)

module test_string_getc_2;
  string s;
  byte c;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: First char
    s = "Hello";
    c = s.getc(0);
    if (c == "H") pass_count++;

    // Test 2: Second char
    c = s.getc(1);
    if (c == "e") pass_count++;

    // Test 3: Last char
    c = s.getc(4);
    if (c == "o") pass_count++;

    $display("String getc tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: String getc tests");
    end else begin
      $display("FAIL: Some string getc tests failed");
    end
  end
endmodule
