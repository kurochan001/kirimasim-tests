/*
:name: test_illegal_type_operator_dynamic_array_element
:description: the expression of a type operator shall not refer to an element of a dynamic object such as a dynamic array (IEEE 1800-2023 Section 6.23)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.23
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the type operator in the declaration of v is applied to da[0], an element of the dynamic array da
:expected_stderr_regex: test_illegal_type_operator_dynamic_array_element\.sv:27:
*/
// IEEE 1800-2023 §6.23: the expression of a type operator is not evaluated
// and shall not contain references to elements of dynamic objects. The
// declaration of ok applies the type operator to an element of the
// fixed-size array fa and is legal; the declaration of v applies it to an
// element of the dynamic array da.
// Icarus Verilog 13.0 does not parse type references and reports syntax
// errors on both declarations, an unsupported construct that is not this
// rule. Verilator 5.052 accepts the design.

module test_illegal_type_operator_dynamic_array_element;
  bit [4:0] fa [2];
  bit [4:0] da [];
  var type(fa[0]) ok;
  var type(da[0]) v;   // illegal: element of a dynamic array
  initial begin
    ok = 5'd1;
    v = 5'd2;
  end
endmodule
