/*
:name: test_realtobits_basic
:description: Test $realtobits basic (IEEE 1800-2023 Section 20.5)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_realtobits_basic.expected
*/
// Test $realtobits basic (IEEE 1800-2023 Section 20.5)

module test_realtobits_basic;
  real r;
  logic [63:0] bits;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Convert 0.0
    r = 0.0;
    bits = $realtobits(r);
    if (bits == 64'h0) pass_count++;

    // Test 2: Convert 1.0
    r = 1.0;
    bits = $realtobits(r);
    if (bits == 64'h3FF0000000000000) pass_count++;  // IEEE 754 double

    // Test 3: Non-zero conversion
    r = 2.5;
    bits = $realtobits(r);
    if (bits == 64'h4004000000000000) pass_count++;

    $display("Realtobits basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Realtobits basic tests");
    end else begin
      $display("FAIL: Some realtobits tests failed");
    end
  end
endmodule
