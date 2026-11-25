/*
:name: test_evcd_keyword_sections_extend_vcd
:description: Paired VCD and extended VCD expose matching dump controls and the extended closing command
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.3.6 21.7.2.3 21.7.3 21.7.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: paired keyword fixture finished
*/

`timescale 1ns/1ns
module keyword_pair_ports(input wire a, output wire y);
  assign y = ~a;
endmodule

module test_evcd_keyword_sections_extend_vcd;
  bit a = 0;
  wire y;
  keyword_pair_ports target(a, y);

  initial begin
    $dumpfile("paired.vcd");
    $dumpvars(1, target);
    $dumpports(target, "paired.evcd");
    #2 a = 1;
    #1 $dumpall;
    $dumpportsall("paired.evcd");
    #1 $dumpoff;
    $dumpportsoff("paired.evcd");
    #1 a = 0;
    #1 $dumpon;
    $dumpportson("paired.evcd");
    #1 a = 1;
    #2 $display("paired keyword fixture finished");
  end
endmodule
