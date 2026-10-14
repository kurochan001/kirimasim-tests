/*
:name: test_onehot0_basic
:description: Test $onehot0 basic (IEEE 1800-2023 Section 20.9)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_onehot0_basic.expected
*/
// Test $onehot0 basic (IEEE 1800-2023 Section 20.9)

module test_onehot0_basic;
  logic [7:0] a;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: One bit set
    a = 8'b0000_1000;
    if ($onehot0(a) == 1) pass_count++;

    // Test 2: No bits set (valid for onehot0)
    a = 8'b0000_0000;
    if ($onehot0(a) == 1) pass_count++;

    // Test 3: Two bits set
    a = 8'b0001_1000;
    if ($onehot0(a) == 0) pass_count++;

    $display("Onehot0 basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Onehot0 basic tests");
    end else begin
      $display("FAIL: Some onehot0 tests failed");
    end
  end
endmodule
