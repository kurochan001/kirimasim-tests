/*
:name: test_illegal_udp_z_in_state_field
:description: A UDP table supports only the states 0, 1 and x, so z cannot be written in the current state field (IEEE 1800-2023 Section 29.3.4)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.4 29.3.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the current state field of a table entry is z
:expected_stderr_regex: test_illegal_udp_z_in_state_field\.sv:24:
*/
// IEEE 1800-2023 §29.3.4: the rows of a UDP table use the states 0, 1
// and x; z is excluded from UDPs, and a z table entry is illegal (29.3.5).
// The second entry of this sequential UDP has z as its current state.

primitive test_illegal_udp_z_in_state_field_p(q, c);
  output q;
  reg q;
  input c;
  table
    r : ? : 1;
    f : z : 0;   // illegal: z in the current state field
  endtable
endprimitive

module test_illegal_udp_z_in_state_field;
  logic c = 0;
  wire q;
  test_illegal_udp_z_in_state_field_p u(q, c);
endmodule
