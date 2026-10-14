/*
:name: test_concat_basic
:description: Test concatenation operator (IEEE 1800-2023 Section 11.4.12)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concat_basic.expected
*/
// Test concatenation operator (IEEE 1800-2023 Section 11.4.12)

module test_concat_basic;
  logic [7:0] a, b;
  logic [15:0] result;
  int pass_count;

  initial begin
    pass_count = 0;
    a = 8'hAB;
    b = 8'hCD;

    // Test 1: Basic concat
    result = {a, b};
    if (result == 16'hABCD) pass_count++;

    // Test 2: Concat with literals
    result = {8'h12, 8'h34};
    if (result == 16'h1234) pass_count++;

    // Test 3: Concat result in expression
    if ({a, b} == 16'hABCD) pass_count++;

    $display("Concat tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Concat tests");
    end else begin
      $display("FAIL: Some concat tests failed");
    end
  end
endmodule
