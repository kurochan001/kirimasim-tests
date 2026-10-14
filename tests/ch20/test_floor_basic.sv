/*
:name: test_floor_basic
:description: Test $floor basic (IEEE 1800-2023 Section 20.8)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_floor_basic.expected
*/
// Test $floor basic (IEEE 1800-2023 Section 20.8)

module test_floor_basic;
  real r;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: floor(3.7) = 3
    r = $floor(3.7);
    if (r == 3.0) pass_count++;

    // Test 2: floor(3.0) = 3
    r = $floor(3.0);
    if (r == 3.0) pass_count++;

    // Test 3: floor(-2.3) = -3
    r = $floor(-2.3);
    if (r == -3.0) pass_count++;

    $display("Floor basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Floor basic tests");
    end else begin
      $display("FAIL: Some floor tests failed");
    end
  end
endmodule
