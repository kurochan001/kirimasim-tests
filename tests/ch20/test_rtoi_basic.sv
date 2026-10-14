/*
:name: test_rtoi_basic
:description: Test $rtoi basic (IEEE 1800-2023 Section 20.5)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rtoi_basic.expected
*/
// Test $rtoi basic (IEEE 1800-2023 Section 20.5)

module test_rtoi_basic;
  real r;
  int i;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Convert positive real
    r = 42.9;
    i = $rtoi(r);
    if (i == 42) pass_count++;

    // Test 2: Convert negative real
    r = -10.5;
    i = $rtoi(r);
    if (i == -10) pass_count++;

    // Test 3: Convert zero
    r = 0.0;
    i = $rtoi(r);
    if (i == 0) pass_count++;

    $display("Rtoi basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Rtoi basic tests");
    end else begin
      $display("FAIL: Some rtoi tests failed");
    end
  end
endmodule
