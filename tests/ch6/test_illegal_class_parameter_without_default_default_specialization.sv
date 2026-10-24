/*
:name: test_illegal_class_parameter_without_default_default_specialization
:description: every specialization of a class whose parameter has no default value has to override that parameter; the class name without a parameter list does not (IEEE 1800-2023 Section 6.20.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable plain is declared with the class name counter_c alone, a specialization that does not give the parameter STEP, which has no default
:expected_stderr_regex: test_illegal_class_parameter_without_default_default_specialization\.sv:34:
*/
// IEEE 1800-2023 §6.20.1: if a parameter of a class has no default value, an
// overriding value shall be given in every specialization of the class
// (8.25). counter_c#(3) and counter_c#(.STEP(5)) give STEP; the class name
// used alone, without a parameter value assignment, names a specialization
// that gives none. A class with a default, step_c, can be used alone.
// Icarus Verilog 13.0 does not support parameterized classes and reports
// syntax errors on their declarations and on every use of them, the line of
// plain included; those errors do not count.

module test_illegal_class_parameter_without_default_default_specialization;
  class counter_c #(parameter int STEP);
    static function int next(int x); return x + STEP; endfunction
  endclass
  class step_c #(parameter int STEP = 2);
    static function int next(int x); return x + STEP; endfunction
  endclass
  counter_c #(3) by_position;
  counter_c #(.STEP(5)) by_name;
  step_c with_default;
  initial $display("%0d %0d", counter_c#(3)::next(1), step_c#()::next(1));
  counter_c plain;   // illegal: STEP is not given
endmodule
