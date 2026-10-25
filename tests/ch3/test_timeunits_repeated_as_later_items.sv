/*
:name: test_timeunits_repeated_as_later_items
:description: A timeunit or timeprecision declaration that repeats the one at the start of a module, interface or program can appear again among its later items, and the time unit and precision stay as first declared (IEEE 1800-2023 Section 3.14.2.2)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.2 3.14.1 20.3.3 24.3 A.1.4 A.1.6 A.1.7 A.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunits_repeated_as_later_items.expected
*/
// IEEE 1800-2023 §3.14.2.2: the timeunit and timeprecision declarations of a
// time scope come before its other items, and they can be repeated as later
// items when they match the earlier ones. A.1.4, A.1.6 and A.1.7 allow such a
// timeunits_declaration as an item of a module, an interface and a program,
// and A.10 note 3 limits it to a matching repetition. Each design element
// below declares a unit and a finer precision, repeats one of the two
// declarations after other items, and then waits for a fractional delay; the
// delay is rounded to the first declared precision (§3.14.1) and $realtime
// gives the time in the first declared unit (§20.3.3). A repetition that
// redefined the scope, for example "timeunit 1ns;" dropping the precision of
// 100ps, would change the rounding:
//   interface tr_if  100ps, 10ps   #2.347  -> 230ps   (2.3000)
//   module    tr_mod 1ns, 100ps    #1.27   -> 1.3ns   (1.3000)
//   program   tr_prg 1ns, 1ps      #3.1416 -> 3.142ns (3.1420)
// The program waits from a generate block (a program_generate_item), and its
// delay is the last one, as the end of the program ends the simulation (24.3).
// The 5.052 release of Verilator rounds the first two delays to the finest
// precision of the design (1ps) and prints 2.3500 and 1.2700.

interface tr_if;
  timeunit 100ps;
  timeprecision 10ps;
  int count = 0;
  timeunit 100ps;
  initial #2.347 $display("tr_if %0.4f", $realtime);
endinterface

module tr_mod;
  timeunit 1ns;
  timeprecision 100ps;
  logic flag = 1'b1;
  timeunit 1ns;
  initial #1.27 $display("tr_mod %0.4f flag=%b", $realtime, flag);
endmodule

program tr_prg;
  timeprecision 1ps;
  timeunit 1ns;
  int steps = 3;
  timeprecision 1ps;
  if (1) begin : g_wait
    initial #3.1416 $display("tr_prg %0.4f steps=%0d", $realtime, steps);
  end
endprogram

module test_timeunits_repeated_as_later_items;
  timeunit 1ns;
  timeprecision 1ps;
  tr_if u_if();
  tr_mod u_mod();
  tr_prg u_prg();
endmodule
