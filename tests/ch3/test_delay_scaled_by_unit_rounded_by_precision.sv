/*
:name: test_delay_scaled_by_unit_rounded_by_precision
:description: The same delay literal waits for different times in modules with different time units, and a delay is rounded to the time precision of its module, so #1.26 is 1 ns, 12.6 ns or 13 ns and #0.0237 and #0.0251 with a 10 ns precision are 20 ns and 30 ns (IEEE 1800-2023 Section 3.14)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14 3.14.1 3.14.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_delay_scaled_by_unit_rounded_by_precision.expected
*/
// IEEE 1800-2023 §3.14: a time value has a time unit, the unit in which
// delays are measured, and a time precision, the accuracy of the delays.
// §3.14.1: a delay is rounded off to the time precision of its design
// element, even when another element has a finer one. §3.14.2.2: timeunit
// and timeprecision set them for a module.
// Each module rd_* sets its variable done to 1 after one delay:
// - rd_1ns_1ns (unit 1ns, precision 1ns): #1.26 is 1.26 ns, rounded to 1 ns;
// - rd_10ns_100ps (unit 10ns, precision 100ps): #1.26 is 12.6 ns;
// - rd_10ns_1ns (unit 10ns, precision 1ns): #1.26 is 12.6 ns, rounded to
//   13 ns;
// - rd_1us_10ns_lo and rd_1us_10ns_hi (unit 1us, precision 10ns): #0.0237
//   and #0.0251 are 23.7 ns and 25.1 ns, rounded to 20 ns and 30 ns.
// The top module, with the unit and precision 1ps, waits for each rising
// edge of done and prints $time in picoseconds. The times differ, so the
// lines come in the order of the times.
// The 5.052 release of Verilator does not round the delays to the precision
// of their module: it waits 1.26 ns, 12.6 ns, 12.6 ns, 23.7 ns and 25.1 ns.

module rd_1ns_1ns;
  timeunit 1ns;
  timeprecision 1ns;
  logic done = 1'b0;

  initial #1.26 done = 1'b1;
endmodule

module rd_10ns_100ps;
  timeunit 10ns;
  timeprecision 100ps;
  logic done = 1'b0;

  initial #1.26 done = 1'b1;
endmodule

module rd_10ns_1ns;
  timeunit 10ns;
  timeprecision 1ns;
  logic done = 1'b0;

  initial #1.26 done = 1'b1;
endmodule

module rd_1us_10ns_lo;
  timeunit 1us;
  timeprecision 10ns;
  logic done = 1'b0;

  initial #0.0237 done = 1'b1;
endmodule

module rd_1us_10ns_hi;
  timeunit 1us;
  timeprecision 10ns;
  logic done = 1'b0;

  initial #0.0251 done = 1'b1;
endmodule

module test_delay_scaled_by_unit_rounded_by_precision;
  timeunit 1ps;
  timeprecision 1ps;

  rd_1ns_1ns u_1ns_1ns();
  rd_10ns_100ps u_10ns_100ps();
  rd_10ns_1ns u_10ns_1ns();
  rd_1us_10ns_lo u_1us_10ns_lo();
  rd_1us_10ns_hi u_1us_10ns_hi();

  always @(posedge u_1ns_1ns.done) $display("unit 1ns, precision 1ns, #1.26: %0d ps", $time);
  always @(posedge u_10ns_100ps.done)
    $display("unit 10ns, precision 100ps, #1.26: %0d ps", $time);
  always @(posedge u_10ns_1ns.done) $display("unit 10ns, precision 1ns, #1.26: %0d ps", $time);
  always @(posedge u_1us_10ns_lo.done)
    $display("unit 1us, precision 10ns, #0.0237: %0d ps", $time);
  always @(posedge u_1us_10ns_hi.done)
    $display("unit 1us, precision 10ns, #0.0251: %0d ps", $time);
endmodule
