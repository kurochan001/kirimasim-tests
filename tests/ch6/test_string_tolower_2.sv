/*
:name: test_string_tolower_2
:description: Test string tolower (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.5
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_tolower_2.expected
*/
// Test string tolower (IEEE 1800-2023 Section 6.16)

module test_string_tolower_2;
  string s, lower;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Uppercase
    s = "HELLO";
    lower = s.tolower();
    if (lower == "hello") pass_count++;

    // Test 2: Mixed case
    s = "HeLLo";
    lower = s.tolower();
    if (lower == "hello") pass_count++;

    // Test 3: Already lower
    s = "world";
    lower = s.tolower();
    if (lower == "world") pass_count++;

    $display("String tolower tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: String tolower tests");
    end else begin
      $display("FAIL: Some string tolower tests failed");
    end
  end
endmodule
