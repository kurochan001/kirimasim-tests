/*
:name: test_illegal_localparam_type_without_default_in_port_list
:description: a type parameter in a parameter port list may have no default type, but a localparam type there may not (IEEE 1800-2023 Section 6.20.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the localparam type L_T in the parameter port list has no data type
:expected_stderr_regex: test_illegal_localparam_type_without_default_in_port_list\.sv:22:
*/
// IEEE 1800-2023 §6.20.1 (footnote 22 of Syntax 6-6): the data type of a
// type_assignment may be left out only in a parameter port list, and even
// there not in a localparam declaration. T, a type parameter without a
// default, is overridden by the instance; L_T is a localparam type of the
// same port list without a data type.

module test_illegal_localparam_type_without_default_in_port_list_m
    #(parameter type T,
      localparam type L_T) ();   // illegal: localparam type without a type
  T v = 5;
  initial $display("%0d", v);
endmodule

module test_illegal_localparam_type_without_default_in_port_list;
  test_illegal_localparam_type_without_default_in_port_list_m #(.T(byte)) u();
endmodule
