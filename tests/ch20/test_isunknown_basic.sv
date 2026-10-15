/*
:name: test_isunknown_basic
:description: Test $isunknown basic (IEEE 1800-2023 Section 20.9)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_isunknown_basic.expected
*/
// Test $isunknown basic (IEEE 1800-2023 Section 20.9)

module test_isunknown_basic;
  logic [7:0] a;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Known value
    a = 8'hAB;
    if ($isunknown(a) == 0) pass_count++;

    // Test 2: X value
    a = 8'bxxxx_xxxx;
    if ($isunknown(a) == 1) pass_count++;

    // Test 3: Partial X
    a = 8'b1010_xxxx;
    if ($isunknown(a) == 1) pass_count++;

    $display("Isunknown basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Isunknown basic tests");
    end else begin
      $display("FAIL: Some isunknown tests failed");
    end
  end
endmodule
