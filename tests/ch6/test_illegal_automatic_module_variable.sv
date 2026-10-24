/*
:name: test_illegal_automatic_module_variable
:description: a data declaration outside a procedural context cannot use the automatic keyword (IEEE 1800-2023 Section 6.8)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module item bad, which is not in a procedural context, is declared automatic
:expected_stderr_regex: test_illegal_automatic_module_variable\.sv:28:
*/
// IEEE 1800-2023 §6.8 (footnote 14 of Syntax 6-3): the automatic keyword is
// illegal in a data declaration that is not within a procedural context.
// The module declares one variable with an explicit static lifetime, which
// is legal there, and the initial procedure declares an automatic variable,
// which is legal in a procedural context; the module item bad is automatic.
// Icarus Verilog 13.0 does not support an explicit lifetime on a variable
// and reports that as not supported, which does not count.

module test_illegal_automatic_module_variable;
  static int kept = 2;
  initial begin
    automatic int local_copy = kept + 1;
    $display("%0d", local_copy);
  end
  automatic int bad;   // illegal: automatic outside a procedural context
endmodule
