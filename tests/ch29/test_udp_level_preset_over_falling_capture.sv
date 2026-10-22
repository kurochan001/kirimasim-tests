/*
:name: test_udp_level_preset_over_falling_capture
:description: A level sensitive preset dominates an overlapping falling edge data capture in a sequential UDP (IEEE 1800-2023 Section 29.9)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.9 29.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_level_preset_over_falling_capture.expected
*/
// IEEE 1800-2023 29.9 29.10: The level entry forces one even when the edge
// entry would capture zero; releasing preset retains the current output until
// another data clock event.
// Oracle checks: The 5.052 release is a two-state engine and is not used as the
// oracle here.

primitive preset_udp(q, clk, data, preset);
  output q;
  reg q;
  input clk, data, preset;
  table
    f 0 ? : ? : 0;
    f 1 ? : ? : 1;
    r ? ? : ? : -;
    ? * ? : ? : -;
    ? ? 1 : ? : 1;
    ? ? (10) : ? : -;
  endtable
endprimitive
module test_udp_level_preset_over_falling_capture;
  reg clk = 1, data = 0, preset = 1;
  wire q;
  preset_udp u(q, clk, data, preset);
  initial begin
    #1 preset = 0;
    #1 clk = 0;
    #1 $display("captured=%b", q);
    clk = 1;
    #1 preset = 1;
    #1 clk = 0;
    #1 $display("preset_over_edge=%b", q);
  end
endmodule
