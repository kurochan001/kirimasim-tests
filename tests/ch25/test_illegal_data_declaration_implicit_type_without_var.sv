/*
:name: test_illegal_data_declaration_implicit_type_without_var
:description: A data declaration that omits the explicit data type needs the keyword var, so static v = 0 in a block is illegal, while var static w = 1 is legal (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the block declaration of v has neither an explicit data type nor the keyword var
:expected_stderr_regex: test_illegal_data_declaration_implicit_type_without_var\.sv:24:
*/
// IEEE 1800-2023 §25.9, footnote 14 of Syntax 25-3: in a data_declaration it
// shall be illegal to omit the explicit data_type before the list of variable
// declaration assignments unless the var keyword is used. In the block of the
// initial procedure, w has var and an implicit type, which is legal (a
// one-bit logic, 6.8); v has the lifetime static and neither var nor a data
// type.

module test_illegal_data_declaration_implicit_type_without_var;
  initial begin : blk
    var static w = 1'b1;
    static v = 1'b0;   // illegal: no data type and no var
    $display("%b", w);
  end
endmodule
