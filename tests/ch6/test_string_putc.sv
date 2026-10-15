/*
:name: test_string_putc
:description: Test string putc (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_putc.expected
*/
// Test string putc (IEEE 1800-2023 Section 6.16)

module test_string_putc;
  string s;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Modify first char
    s = "Hello";
    s.putc(0, "J");
    if (s == "Jello") pass_count++;

    // Test 2: Modify middle
    s = "Hello";
    s.putc(2, "a");
    if (s == "Healo") pass_count++;

    // Test 3: Modify last
    s = "Hello";
    s.putc(4, "a");
    if (s == "Hella") pass_count++;

    $display("String putc tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: String putc tests");
    end else begin
      $display("FAIL: Some string putc tests failed");
    end
  end
endmodule
