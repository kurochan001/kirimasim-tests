/*
:name: test_illegal_udp_contains_gate_instance
:description: A user-defined primitive that contains an instance of a gate is rejected (IEEE 1800-2023 Section 3.11)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.11 29.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the body of the user-defined primitive contains a gate instance, but a primitive cannot instantiate other building blocks
:expected_stderr_regex: test_illegal_udp_contains_gate_instance\.sv:22:
*/
// IEEE 1800-2023 §3.11: primitives are leaves of the hierarchy tree and
// cannot instantiate other building blocks; a UDP body has only its port
// declarations and its state table (§29.3). The module instantiates the
// UDP, which is legal; the not gate instance inside the UDP, on the marked
// line, is an error. Verilator 5.052 accepts the design, which the clause
// does not allow.

primitive test_illegal_udp_contains_gate_instance_inv(output o, input a);
  not g_inner(o, a);   // illegal: an instance inside a primitive
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive

module test_illegal_udp_contains_gate_instance;
  wire o;
  test_illegal_udp_contains_gate_instance_inv u(o, 1'b0);

  initial #1 $display("o=%b", o);
endmodule
