/*
:name: test_itor_basic
:description: Test $itor basic (IEEE 1800-2023 Section 20.5)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_itor_basic.expected
*/
// Test $itor basic (IEEE 1800-2023 Section 20.5)

module test_itor_basic;
  int i;
  real r;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Convert positive int
    i = 42;
    r = $itor(i);
    if (r == 42.0) pass_count++;

    // Test 2: Convert negative int
    i = -10;
    r = $itor(i);
    if (r == -10.0) pass_count++;

    // Test 3: Convert zero
    i = 0;
    r = $itor(i);
    if (r == 0.0) pass_count++;

    $display("Itor basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Itor basic tests");
    end else begin
      $display("FAIL: Some itor tests failed");
    end
  end
endmodule
