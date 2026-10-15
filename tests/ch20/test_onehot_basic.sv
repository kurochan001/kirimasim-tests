/*
:name: test_onehot_basic
:description: Test $onehot basic (IEEE 1800-2023 Section 20.9)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_onehot_basic.expected
*/
// Test $onehot basic (IEEE 1800-2023 Section 20.9)

module test_onehot_basic;
  logic [7:0] a;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: One bit set
    a = 8'b0000_1000;
    if ($onehot(a) == 1) pass_count++;

    // Test 2: Two bits set
    a = 8'b0001_1000;
    if ($onehot(a) == 0) pass_count++;

    // Test 3: No bits set
    a = 8'b0000_0000;
    if ($onehot(a) == 0) pass_count++;

    $display("Onehot basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Onehot basic tests");
    end else begin
      $display("FAIL: Some onehot tests failed");
    end
  end
endmodule
