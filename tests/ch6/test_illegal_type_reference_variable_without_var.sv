/*
:name: test_illegal_type_reference_variable_without_var
:description: a variable declaration whose data type is a type reference shall start with the var keyword (IEEE 1800-2023 Section 6.23)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.23
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the declaration of bad uses the type reference type(a) as its data type without the var keyword
:expected_stderr_regex: test_illegal_type_reference_variable_without_var\.sv:25:
*/
// IEEE 1800-2023 §6.23: when a type reference is used in a variable
// declaration, it shall be preceded by the keyword var. The declaration of
// good has var and is legal; the declaration of bad starts with the type
// reference itself.
// Icarus Verilog 13.0 does not parse type references and reports syntax
// errors on both declarations, an unsupported construct that is not this
// rule. Verilator 5.052 accepts the design.

module test_illegal_type_reference_variable_without_var;
  logic [3:0] a;
  var type(a) good;
  type(a) bad;   // illegal: no var before the type reference
  initial begin
    good = 4'd3;
    bad = 4'd4;
  end
endmodule
