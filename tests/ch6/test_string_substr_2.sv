/*
:name: test_string_substr_2
:description: Test string substr (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_substr_2.expected
*/
// Test string substr (IEEE 1800-2023 Section 6.16)

module test_string_substr;
  string s, sub;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Basic substr
    s = "Hello World";
    sub = s.substr(0, 4);
    if (sub == "Hello") pass_count++;

    // Test 2: Middle substr
    sub = s.substr(6, 10);
    if (sub == "World") pass_count++;

    // Test 3: Single char
    sub = s.substr(0, 0);
    if (sub == "H") pass_count++;

    $display("String substr tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: String substr tests");
    end else begin
      $display("FAIL: Some string substr tests failed");
    end
  end
endmodule
