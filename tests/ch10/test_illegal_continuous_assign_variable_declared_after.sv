/*
:name: test_illegal_continuous_assign_variable_declared_after
:description: a variable has to be declared before a continuous assignment to it, while a net may also be declared implicitly by one (IEEE 1800-2023 Section 10.3.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable v_late is declared only after the continuous assignment to it
:expected_stderr_regex: test_illegal_continuous_assign_variable_declared_after\.sv:(28|29):
*/
// IEEE 1800-2023 §10.3.2: the target of a continuous assignment may be a net
// declared explicitly or one that gets an implicit declaration (6.10), but a
// variable shall be declared explicitly before the continuous assignment.
// v_ok is declared first, and n_imp is an implicit scalar net, which is legal;
// v_late is declared after its continuous assignment. A tool can report the
// assignment or the declaration.
// The design is accepted by Verilator 5.052.

module test_illegal_continuous_assign_variable_declared_after;
  logic a = 1'b1;
  logic v_ok;

  assign v_ok = a;
  assign n_imp = a;
  assign v_late = a;   // (or reported here)
  logic v_late;   // illegal: declared after the continuous assignment

  initial #1 $display("%b %b", v_ok, n_imp);
endmodule
