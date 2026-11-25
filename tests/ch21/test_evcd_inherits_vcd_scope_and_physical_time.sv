/*
:name: test_evcd_inherits_vcd_scope_and_physical_time
:description: VCD and extended VCD describe the same nested scope and physical times for paired signal changes
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.3 21.7.4.1 21.7.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: time pair fixture finished
*/

`timescale 1ns/10ps
module physical_time_ports(input wire a, output wire y);
  assign y = ~a;
endmodule

module test_evcd_inherits_vcd_scope_and_physical_time;
  bit a = 0;
  wire y;
  physical_time_ports target(a, y);

  initial begin
    $dumpfile("timed.vcd");
    $dumpvars(1, target);
    $dumpports(target, "timed.evcd");
    #0.07 a = 1;
    #0.11 a = 0;
    #0.05 $display("time pair fixture finished");
  end
endmodule
