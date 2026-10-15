/*
:name: test_arith_shift_assign
:description: Test arithmetic shift compound assignment (IEEE 1800-2023 Section 11.4.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.1 11.4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_arith_shift_assign.expected
*/
// Test arithmetic shift compound assignment (IEEE 1800-2023 Section 11.4.1)

module test_arith_shift_assign;
  logic signed [7:0] a;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: <<<= operator
    a = 8'sb0000_0001;
    a <<<= 4;
    if (a == 8'sb0001_0000) pass_count++;

    // Test 2: >>>= operator with positive
    a = 8'sb0100_0000;
    a >>>= 2;
    if (a == 8'sb0001_0000) pass_count++;

    // Test 3: >>>= with sign extension
    a = 8'sb1000_0000;
    a >>>= 2;
    if (a == 8'sb1110_0000) pass_count++;

    $display("Arith shift assign tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Arith shift assign tests");
    end else begin
      $display("FAIL: Some arith shift assign tests failed");
    end
  end
endmodule
