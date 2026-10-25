/*
:name: test_nested_module_inherits_time_unit_and_precision
:description: A module or interface declared inside a module or interface, without its own timeunit and timeprecision, takes both from the enclosing definition and not from the `timescale before them (IEEE 1800-2023 Section 3.14.2.3)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.3 3.14.2.2 3.14.2.1 3.14.1 23.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nested_module_inherits_time_unit_and_precision.expected
*/
// IEEE 1800-2023 §3.14.2.3: when a module or interface definition without a
// timeunit is nested (23.4), its time unit is inherited from the enclosing
// module or interface; this comes before the rule of the last `timescale. The
// time precision follows the same order.
// `timescale 1ns/1ns is in effect for the whole file. tn_outer declares 10ps /
// 10ps (§3.14.2.2); the module tn_inner and the interface tn_inner_if declared
// inside it wait #5.27 and #6.27, which are rounded to whole units of 10 ps
// (§3.14.1): 50 ps and 60 ps. The interface tn_outer_if declares 100ps /
// 100ps; the interface tn_in_if declared inside it (A.1.6) waits #7.27, 7
// units of 100 ps: 700 ps. All report through a task of the top module, whose
// own unit and precision are 1ps, so $time is in picoseconds: a nested
// definition that took the `timescale would wait nanoseconds, and one that
// did not round to the precision of its parent would report 53, 63 or 727 ps.
// Icarus Verilog 13.0 does not support nested definitions ("Unknown module
// type", or for the interface instance in tn_outer_if "Module instantiations
// are not allowed in interfaces"), and release 5.052 of Verilator stops with
// "Unsupported: module decls within module decls".

`timescale 1ns/1ns

module tn_outer;
  timeunit 10ps;
  timeprecision 10ps;

  module tn_inner;
    initial #5.27 test_nested_module_inherits_time_unit_and_precision.report("tn_inner");
  endmodule

  interface tn_inner_if;
    initial #6.27 test_nested_module_inherits_time_unit_and_precision.report("tn_inner_if");
  endinterface

  tn_inner m();
  tn_inner_if i();
endmodule

interface tn_outer_if;
  timeunit 100ps;
  timeprecision 100ps;

  interface tn_in_if;
    initial #7.27 test_nested_module_inherits_time_unit_and_precision.report("tn_in_if");
  endinterface

  tn_in_if i();
endinterface

module test_nested_module_inherits_time_unit_and_precision;
  timeunit 1ps;
  timeprecision 1ps;

  task report(string who);
    $display("%0d ps: %s", $time, who);
  endtask

  tn_outer o();
  tn_outer_if oi();
endmodule
