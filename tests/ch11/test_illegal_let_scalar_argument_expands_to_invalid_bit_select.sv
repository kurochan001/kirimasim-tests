/*
:name: test_illegal_let_scalar_argument_expands_to_invalid_bit_select
:description: A let expansion using an untyped actual is checked after substitution and rejects selection of a scalar
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.12 11.5.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the untyped formal expands to a scalar object at the invalid call
:expected_stderr_regex: (?i)^(?=[^\n]*test_illegal_let_scalar_argument_expands_to_invalid_bit_select\.sv:(?:15|22):)(?=[^\n]*(?:scalar[^\n]*(?:select|index)|(?:select|index)[^\n]*scalar|not indexable|type does not have a bit range[^\n]*data type is 'bit'))[^\n]+
*/
module test_illegal_let_scalar_argument_expands_to_invalid_bit_select;
  let at_index(value, index) = value[index];
  bit vector_result;
  bit [2:0] vector_data = 3'b100;
  bit scalar_data = 1;

  initial begin
    vector_result = at_index(vector_data, 2);
    $display("valid=%b invalid=%b", vector_result, at_index(scalar_data, 0)); // illegal
  end
endmodule
