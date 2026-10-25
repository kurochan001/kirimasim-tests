/*
:name: test_illegal_for_type_reference_without_var
:description: a type reference that declares a for-loop variable has to be preceded by var (IEEE 1800-2023 Section 12.7)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.7 6.23
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the for-loop variable i is declared with the type reference type(limit) without the var keyword
:expected_stderr_regex: test_illegal_for_type_reference_without_var\.sv:27:
*/
// IEEE 1800-2023 §12.7 (footnote 18 of Syntax 12-5), §6.23: when a type
// reference is used in a variable declaration, it shall be preceded by the var
// keyword. A for_variable_declaration declares a variable; the first loop
// declares j with var type(limit), which is legal, and the second declares i
// with type(limit) alone.
// Icarus Verilog 13.0 reports a syntax error here, but it reports one on the
// legal loop as well, as it does not support type references in a for-loop, so
// it does not count; Verilator 5.052 accepts the design.

module test_illegal_for_type_reference_without_var;
  int limit = 2;
  initial begin
    for (var type(limit) j = 0; j < limit; j++) $display("j=%0d", j);
    for (type(limit) i = 0; i < limit; i++) $display("i=%0d", i);   // illegal
  end
endmodule
