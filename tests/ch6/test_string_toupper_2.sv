/*
:name: test_string_toupper_2
:description: Test string toupper (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_toupper_2.expected
*/
// Test string toupper (IEEE 1800-2023 Section 6.16)

module test_string_toupper_2;
  string s, upper;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Lowercase
    s = "hello";
    upper = s.toupper();
    if (upper == "HELLO") pass_count++;

    // Test 2: Mixed case
    s = "Hello";
    upper = s.toupper();
    if (upper == "HELLO") pass_count++;

    // Test 3: Already upper
    s = "WORLD";
    upper = s.toupper();
    if (upper == "WORLD") pass_count++;

    $display("String toupper tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: String toupper tests");
    end else begin
      $display("FAIL: Some string toupper tests failed");
    end
  end
endmodule
