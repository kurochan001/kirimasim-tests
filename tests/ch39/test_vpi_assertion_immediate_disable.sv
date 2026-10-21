/*
:name: test_vpi_assertion_immediate_disable
:description: vpiAssertionDisable on an immediate assertion stops its pass and fail actions (IEEE 1800-2023 Section 39.5.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.2 39.3.1 16.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_immediate_disable.c
:expected_stdout: @test_vpi_assertion_immediate_disable.expected
*/
// IEEE 1800-2023 §39.5.2: vpiAssertionDisable disables one assertion, so its
// pass and fail actions do not run. §39.3.1: the application finds the
// immediate assertion among all assertions of the design at time 0, before its
// procedure first runs. §16.3: the assertion would pass at 15, where v is 1,
// and fail at 25, where v is 0, so with the assertion disabled both counts stay
// 0.

`timescale 1ns/1ns

module test_vpi_assertion_immediate_disable;
  logic clk = 0;
  logic v = 0;
  int passes = 0;
  int fails = 0;

  always #5 clk = ~clk;

  always @(posedge clk) begin
    chk: assert (v) passes++; else fails++;
  end

  initial begin
    $vt_disable;
    #10 v = 1;
    #10 v = 0;
    #10 $display("pass=%0d fail=%0d", passes, fails);
    $finish;
  end
endmodule
