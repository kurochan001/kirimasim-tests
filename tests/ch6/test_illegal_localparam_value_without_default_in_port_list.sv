/*
:name: test_illegal_localparam_value_without_default_in_port_list
:description: a value parameter in a parameter port list may have no default value, but a localparam there may not (IEEE 1800-2023 Section 6.20.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the localparam DEPTH in the parameter port list has no value
:expected_stderr_regex: test_illegal_localparam_value_without_default_in_port_list\.sv:22:
*/
// IEEE 1800-2023 §6.20.1 (footnote 22 of Syntax 6-6): the value of a
// param_assignment may be left out only in a parameter port list, and even
// there not in a localparam declaration. WIDTH, a parameter without a
// default, is overridden by the instance; DEPTH is a localparam of the same
// port list without a value.

module test_illegal_localparam_value_without_default_in_port_list_m
    #(parameter int WIDTH,
      localparam int DEPTH) ();   // illegal: localparam without a value
  initial $display("%0d", WIDTH);
endmodule

module test_illegal_localparam_value_without_default_in_port_list;
  test_illegal_localparam_value_without_default_in_port_list_m #(.WIDTH(4)) u();
endmodule
