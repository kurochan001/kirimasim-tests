/*
:name: test_time_unit_strings_scale_by_1000
:description: Eighteen modules, one for each time unit of 1, 10 or 100 s, ms, us, ns, ps or fs, wait #1; a module with the unit 1fs sees each wait end after the matching number of femtoseconds, each unit string 1000 times the next smaller one (IEEE 1800-2023 Section 3.14)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14 3.14.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_time_unit_strings_scale_by_1000.expected
*/
// IEEE 1800-2023 §3.14: a time unit (and a time precision) is written as one
// of the strings s, ms, us, ns, ps and fs, for seconds, milliseconds,
// microseconds, nanoseconds, picoseconds and femtoseconds (Table 3-1), with
// an order of magnitude of 1, 10 or 100; units range from 100 s down to
// 1 fs. §3.14.2.2: a timeunit declaration sets the time unit of a module.
// Each module tu_<unit> declares one of the 18 units, with the precision
// 1fs, and sets its variable done to 1 after #1, that is after one of its
// own time units. The top module, with the unit and precision 1fs, waits for
// each rising edge of done and prints $time, which is in femtoseconds: 1,
// 10 and 100 fs, then 1000 times as much for each next unit string, up to
// 100 s = 10**17 fs. The waits end at different times, so the lines come in
// the order of the units.

module tu_1fs;
  timeunit 1fs;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_10fs;
  timeunit 10fs;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_100fs;
  timeunit 100fs;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_1ps;
  timeunit 1ps;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_10ps;
  timeunit 10ps;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_100ps;
  timeunit 100ps;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_1ns;
  timeunit 1ns;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_10ns;
  timeunit 10ns;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_100ns;
  timeunit 100ns;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_1us;
  timeunit 1us;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_10us;
  timeunit 10us;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_100us;
  timeunit 100us;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_1ms;
  timeunit 1ms;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_10ms;
  timeunit 10ms;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_100ms;
  timeunit 100ms;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_1s;
  timeunit 1s;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_10s;
  timeunit 10s;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module tu_100s;
  timeunit 100s;
  timeprecision 1fs;
  logic done = 1'b0;

  initial #1 done = 1'b1;
endmodule

module test_time_unit_strings_scale_by_1000;
  timeunit 1fs;
  timeprecision 1fs;

  tu_1fs u_1fs();
  tu_10fs u_10fs();
  tu_100fs u_100fs();
  tu_1ps u_1ps();
  tu_10ps u_10ps();
  tu_100ps u_100ps();
  tu_1ns u_1ns();
  tu_10ns u_10ns();
  tu_100ns u_100ns();
  tu_1us u_1us();
  tu_10us u_10us();
  tu_100us u_100us();
  tu_1ms u_1ms();
  tu_10ms u_10ms();
  tu_100ms u_100ms();
  tu_1s u_1s();
  tu_10s u_10s();
  tu_100s u_100s();

  always @(posedge u_1fs.done) $display("#1 in 1fs:   %0d fs", $time);
  always @(posedge u_10fs.done) $display("#1 in 10fs:  %0d fs", $time);
  always @(posedge u_100fs.done) $display("#1 in 100fs: %0d fs", $time);
  always @(posedge u_1ps.done) $display("#1 in 1ps:   %0d fs", $time);
  always @(posedge u_10ps.done) $display("#1 in 10ps:  %0d fs", $time);
  always @(posedge u_100ps.done) $display("#1 in 100ps: %0d fs", $time);
  always @(posedge u_1ns.done) $display("#1 in 1ns:   %0d fs", $time);
  always @(posedge u_10ns.done) $display("#1 in 10ns:  %0d fs", $time);
  always @(posedge u_100ns.done) $display("#1 in 100ns: %0d fs", $time);
  always @(posedge u_1us.done) $display("#1 in 1us:   %0d fs", $time);
  always @(posedge u_10us.done) $display("#1 in 10us:  %0d fs", $time);
  always @(posedge u_100us.done) $display("#1 in 100us: %0d fs", $time);
  always @(posedge u_1ms.done) $display("#1 in 1ms:   %0d fs", $time);
  always @(posedge u_10ms.done) $display("#1 in 10ms:  %0d fs", $time);
  always @(posedge u_100ms.done) $display("#1 in 100ms: %0d fs", $time);
  always @(posedge u_1s.done) $display("#1 in 1s:    %0d fs", $time);
  always @(posedge u_10s.done) $display("#1 in 10s:   %0d fs", $time);
  always @(posedge u_100s.done) $display("#1 in 100s:  %0d fs", $time);
endmodule
