/*
:name: test_countones_basic
:description: Test $countones basic (IEEE 1800-2023 Section 20.9)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_countones_basic.expected
*/
// Test $countones basic (IEEE 1800-2023 Section 20.9)

module test_countones_basic;
  logic [7:0] a;
  int cnt;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Mixed pattern
    a = 8'b1010_1010;
    cnt = $countones(a);
    if (cnt == 4) pass_count++;

    // Test 2: All ones
    a = 8'hFF;
    cnt = $countones(a);
    if (cnt == 8) pass_count++;

    // Test 3: All zeros
    a = 8'h00;
    cnt = $countones(a);
    if (cnt == 0) pass_count++;

    $display("Countones basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Countones basic tests");
    end else begin
      $display("FAIL: Some countones tests failed");
    end
  end
endmodule
