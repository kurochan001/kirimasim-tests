/*
:name: test_illegal_unit_scope_forward_reference
:description: A reference to a compilation-unit variable that is declared later in the compilation unit is rejected (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: unit_late is declared in the compilation-unit scope only after the module that refers to it
:expected_stderr_regex: test_illegal_unit_scope_forward_reference\.sv:30:
*/
// IEEE 1800-2023 §3.12.1: a simple name is looked up in the nested scopes and
// then only in the part of the compilation-unit scope that comes before the
// reference; apart from task and function names, a reference shall be to a
// name already defined in the compilation unit. unit_early is declared before
// the module and is legal to use; unit_late is declared after it, so the use
// on the marked line is an error. It is not a hierarchical name, so the
// instance hierarchy is not searched for it either. Verilator 5.052 accepts
// the reference and runs the design, which the clause does not allow.

int unit_early = 2;

module test_illegal_unit_scope_forward_reference;
  int sum;

  initial begin
    sum = unit_early;
    sum = sum + unit_late;   // illegal: unit_late is declared later
    $display("sum=%0d", sum);
  end
endmodule

int unit_late = 5;
