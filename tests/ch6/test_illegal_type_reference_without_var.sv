/*
:name: test_illegal_type_reference_without_var
:description: a type_reference used as a variable type without var is illegal
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a type_reference in a variable declaration shall be preceded by var
:expected_stderr_regex: test_illegal_type_reference_without_var\.sv:20:
*/
// IEEE 1800-2023 6.8 footnote 18: a type_reference in a net declaration shall
// be preceded by a net type keyword and in a variable declaration by var. The
// marked declaration uses type() as a variable data type without var, which a
// tool has to reject.

module test_illegal_type_reference_without_var;
  type(logic [3:0]) v; // illegal: missing var before the type_reference

  initial begin
    v = 4'h1;
    $display("%h", v);
  end
endmodule
