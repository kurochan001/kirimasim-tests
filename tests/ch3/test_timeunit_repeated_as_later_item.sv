/*
:name: test_timeunit_repeated_as_later_item
:description: A timeunit or timeprecision declaration can be repeated as a later item of a module, interface or package when it matches the first one, and the time scope keeps that unit and precision for its delays and for $printtimescale (IEEE 1800-2023 Section 3.14.2.2)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.2 20.4.2 A.1.2 A.1.4 A.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunit_repeated_as_later_item.expected
*/
// IEEE 1800-2023 §3.14.2.2 with footnote 3 of A.10: a timeunits_declaration
// that is a later (non-port) item of a module, interface or program, or an
// item of a package, is legal only when it repeats and matches the
// declaration made first in the same time scope. The time scope then keeps
// that time unit and precision.
//
// The top module declares 1ns and 1ps first and repeats both after an
// import and its instances. tu_mod declares 1us and 1ns and repeats them
// in the other order after the variable a. The interface tu_if uses the
// form timeunit 100ps / 10ps and repeats it after the variable flag; its
// delay #5 is 500 ps. The package tu_pkg declares 10ns and 1ns and repeats
// timeunit 10ns after a variable; the delay #2 in its task wait_two is
// 20 ns. $printtimescale shows the unit and precision of the top module,
// m and i; $realtime in the top module counts in ns, so flag rises at 0.500
// and the task returns 20 ns later, at 20.500.
//
// The 5.052 release of Verilator prints the design element name without
// the parentheses of 20.4.2 and, for m and i, the name and the time scale
// of the top module instead of theirs.

package tu_pkg;
  timeunit 10ns;
  timeprecision 1ns;
  int pkg_val = 1;
  timeunit 10ns;

  task automatic wait_two;
    #2;
  endtask
endpackage

interface tu_if;
  timeunit 100ps / 10ps;
  logic flag = 0;
  timeunit 100ps / 10ps;

  initial #5 flag = 1;
endinterface

module tu_mod;
  timeunit 1us;
  timeprecision 1ns;
  int a;
  timeprecision 1ns;
  timeunit 1us;
endmodule

module test_timeunit_repeated_as_later_item;
  timeunit 1ns;
  timeprecision 1ps;
  import tu_pkg::wait_two;
  tu_if i ();
  tu_mod m ();
  timeunit 1ns;
  timeprecision 1ps;

  initial begin
    $printtimescale;
    $printtimescale(test_timeunit_repeated_as_later_item.m);
    $printtimescale(test_timeunit_repeated_as_later_item.i);
    wait (i.flag == 1);
    $display("flag at %0.3f", $realtime);
    wait_two();
    $display("after wait_two at %0.3f", $realtime);
  end
endmodule
