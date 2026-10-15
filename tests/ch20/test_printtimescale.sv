/*
:name: test_printtimescale
:description: Test $printtimescale (IEEE 1800-2023 Section 20.4.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_printtimescale.expected
*/
// Test $printtimescale (IEEE 1800-2023 Section 20.4.2)

`timescale 1ns/1ps

module test_printtimescale;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Printtimescale call
    $printtimescale;
    pass_count++;

    // Test 2: Check time
    #1;
    if ($time == 1) pass_count++;

    // Test 3: Another delay
    #2;
    if ($time == 3) pass_count++;

    $display("Printtimescale tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Printtimescale tests");
    end else begin
      $display("FAIL: Some printtimescale tests failed");
    end
  end
endmodule
