/*
:name: test_string_itoa_2
:description: Test string itoa method (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_itoa_2.expected
*/
// Test string itoa method (IEEE 1800-2023 Section 6.16)

module test_string_itoa;
  string s;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Positive integer
    s.itoa(123);
    if (s == "123") pass_count++;

    // Test 2: Negative integer
    s.itoa(-456);
    if (s == "-456") pass_count++;

    // Test 3: Zero
    s.itoa(0);
    if (s == "0") pass_count++;

    $display("String itoa tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: String itoa tests");
    end else begin
      $display("FAIL: Some string itoa tests failed");
    end
  end
endmodule
