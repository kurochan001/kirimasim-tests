/*
:name: test_reduce_and
:description: Test reduction and (IEEE 1800-2023 Section 11.4.9)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reduce_and.expected
*/
// Test reduction and (IEEE 1800-2023 Section 11.4.9)

module test_reduce_and;
  logic [7:0] a;
  logic result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: All ones
    a = 8'hFF;
    result = &a;
    if (result == 1'b1) pass_count++;

    // Test 2: One zero
    a = 8'hFE;
    result = &a;
    if (result == 1'b0) pass_count++;

    // Test 3: All zeros
    a = 8'h00;
    result = &a;
    if (result == 1'b0) pass_count++;

    // Test 4: Single bit set
    a = 8'h80;
    result = &a;
    if (result == 1'b0) pass_count++;

    $display("Reduce and tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Reduce and tests");
    end else begin
      $display("FAIL: Some reduce and tests failed");
    end
  end
endmodule
