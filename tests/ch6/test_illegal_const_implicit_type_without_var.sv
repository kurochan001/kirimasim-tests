/*
:name: test_illegal_const_implicit_type_without_var
:description: a variable declaration that gives only a packed range instead of a data type needs the var keyword; const with a range alone is illegal (IEEE 1800-2023 Section 6.8)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the const declaration of bad gives only a packed range, with neither a data type nor the var keyword
:expected_stderr_regex: test_illegal_const_implicit_type_without_var\.sv:25:
*/
// IEEE 1800-2023 §6.8 (footnote 14 of Syntax 6-3): a data declaration may
// leave out the data type, keeping only signing and packed dimensions, only
// when it uses the var keyword; the type is then logic. The declarations of
// with_var and with_var_signed keep var and are legal; the declaration of
// bad has const and a range, but no var and no data type.

module test_illegal_const_implicit_type_without_var;
  const var [3:0] with_var = 4'd5;
  const var signed [3:0] with_var_signed = -4'sd2;
  const logic [3:0] with_type = 4'd7;
  initial $display("%0d %0d %0d", with_var, with_var_signed, with_type);
  const [3:0] bad = 4'd6;   // illegal: no data type and no var
endmodule
