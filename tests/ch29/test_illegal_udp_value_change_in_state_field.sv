/*
:name: test_illegal_udp_value_change_in_state_field
:description: A UDP value change (vw) is allowed only in input fields, not in the current state field (IEEE 1800-2023 Section 29.3.6)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the current state field of a table entry is a value change
:expected_stderr_regex: test_illegal_udp_value_change_in_state_field\.sv:25:
*/
// IEEE 1800-2023 §29.3.6, Table 29-1: a value change (vw) is only
// permitted in an input field. The second entry of this sequential UDP
// has (01) in its current state field.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design.

primitive test_illegal_udp_value_change_in_state_field_p(q, c);
  output q;
  reg q;
  input c;
  table
    r : ? : 1;
    f : (01) : 0;   // illegal: value change in the current state field
  endtable
endprimitive

module test_illegal_udp_value_change_in_state_field;
  logic c = 0;
  wire q;
  test_illegal_udp_value_change_in_state_field_p u(q, c);
endmodule
