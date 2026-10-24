/*
:name: test_illegal_time_unit_specified_only_in_some_elements
:description: A design in which one module specifies its time unit and precision and another does not, with no `timescale before it, is rejected (IEEE 1800-2023 Section 3.14.2.3)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.14.2.3 3.14.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the top module specifies a time unit and precision while the module it instantiates has none, from no declaration, directive or compilation-unit setting
:expected_stderr_regex: test_illegal_time_unit_specified_only_in_some_elements\.sv:(24|29|30):
*/
// IEEE 1800-2023 §3.14.2.3: a design element without timeunit and
// timeprecision declarations takes its time unit and precision from an
// enclosing module or interface, the last earlier `timescale, or the
// compilation-unit scope, and otherwise from the default; it shall be an
// error if some design elements have a time unit and precision specified and
// others do not. No `timescale or compilation-unit declaration precedes the
// first module, so it has neither, while the top module declares both. The
// error can be reported at the module without them or at either declaration
// of the top module. Icarus Verilog 13.0 and Verilator 5.052 only warn.

module test_illegal_time_unit_specified_only_in_some_elements_child;
  initial #1 $display("child");
endmodule

module test_illegal_time_unit_specified_only_in_some_elements;
  timeunit 1ns;
  timeprecision 1ns;

  test_illegal_time_unit_specified_only_in_some_elements_child u_child();

  initial #2 $display("top");
endmodule
