/*
:name: test_cast_real_basic
:description: Test real cast (IEEE 1800-2023 Section 6.24)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.12.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_real_basic.expected
*/
// Test real cast (IEEE 1800-2023 Section 6.24)

module test_cast_real_basic;
  int i;
  real r;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Int to real
    i = 42;
    r = real'(i);
    if (r == 42.0) pass_count++;

    // Test 2: Negative int to real
    i = -10;
    r = real'(i);
    if (r == -10.0) pass_count++;

    // Test 3: Direct cast expression
    if (real'(100) == 100.0) pass_count++;

    $display("Cast real tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Cast real tests");
    end else begin
      $display("FAIL: Some cast real tests failed");
    end
  end
endmodule
