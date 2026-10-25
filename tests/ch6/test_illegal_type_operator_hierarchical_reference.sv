/*
:name: test_illegal_type_operator_hierarchical_reference
:description: the expression of a type operator shall not contain a hierarchical reference (IEEE 1800-2023 Section 6.23)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.23
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the type operator in the declaration of v is applied to the hierarchical reference u.w
:expected_stderr_regex: test_illegal_type_operator_hierarchical_reference\.sv:31:
*/
// IEEE 1800-2023 §6.23: type(expression) stands for the self-determined type
// of the expression, which is not evaluated and shall not contain any
// hierarchical reference. The declaration of ok applies the type operator
// to the local variable w and is legal; the declaration of v applies it to
// u.w, the variable w of the instance u reached through the hierarchy.
// Icarus Verilog 13.0 does not parse type references and reports syntax
// errors on both declarations, an unsupported construct that is not this
// rule. Verilator 5.052 accepts the design.

module test_illegal_type_operator_hierarchical_reference_child;
  logic [5:0] w;
endmodule

module test_illegal_type_operator_hierarchical_reference;
  logic [5:0] w;
  test_illegal_type_operator_hierarchical_reference_child u ();
  var type(w) ok;
  var type(u.w) v;   // illegal: hierarchical reference in a type operator
  initial begin
    ok = 6'd1;
    v = 6'd2;
  end
endmodule
