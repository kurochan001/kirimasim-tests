/*
:name: test_abs_func
:description: Absolute value (IEEE 1800-2023)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_abs_func.expected
*/
// Absolute value (IEEE 1800-2023)

module test_abs_func;
  int i_val;
  real r_val;
  int pass_count;

  function int abs_int(int x);
    return (x < 0) ? -x : x;
  endfunction

  initial begin
    pass_count = 0;

    // Test 1: Positive int
    i_val = abs_int(42);
    if (i_val == 42) pass_count++;

    // Test 2: Negative int
    i_val = abs_int(-42);
    if (i_val == 42) pass_count++;

    // Test 3: Zero
    i_val = abs_int(0);
    if (i_val == 0) pass_count++;

    // Test 4: Large positive
    i_val = abs_int(1000000);
    if (i_val == 1000000) pass_count++;

    // Test 5: Large negative
    i_val = abs_int(-1000000);
    if (i_val == 1000000) pass_count++;

    // Test 6: Edge case -1
    i_val = abs_int(-1);
    if (i_val == 1) pass_count++;

    $display("Abs tests: %0d/6 passed", pass_count);
    if (pass_count == 6) begin
      $display("PASS: Abs tests");
    end else begin
      $display("FAIL: Some abs tests failed");
    end
  end
endmodule
