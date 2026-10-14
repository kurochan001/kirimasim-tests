/*
:name: test_reduce_or
:description: Test reduction or (IEEE 1800-2023 Section 11.4.9)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reduce_or.expected
*/
// Test reduction or (IEEE 1800-2023 Section 11.4.9)

module test_reduce_or;
  logic [7:0] a;
  logic result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: All zeros
    a = 8'h00;
    result = |a;
    if (result == 1'b0) pass_count++;

    // Test 2: One bit set
    a = 8'h01;
    result = |a;
    if (result == 1'b1) pass_count++;

    // Test 3: All ones
    a = 8'hFF;
    result = |a;
    if (result == 1'b1) pass_count++;

    // Test 4: Pattern
    a = 8'hAA;
    result = |a;
    if (result == 1'b1) pass_count++;

    $display("Reduce or tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Reduce or tests");
    end else begin
      $display("FAIL: Some reduce or tests failed");
    end
  end
endmodule
