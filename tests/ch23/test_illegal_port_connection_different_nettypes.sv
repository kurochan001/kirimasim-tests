/*
:name: test_illegal_port_connection_different_nettypes
:description: When both sides of a port connection are nets of user-defined nettypes, the nettypes have to match (IEEE 1800-2023 Section 23.3.3)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the port of type volt_t is connected to a net of the other nettype amp_t, although both have the data type real
:expected_stderr_regex: test_illegal_port_connection_different_nettypes\.sv:36:
*/
// IEEE 1800-2023 §23.3.3: if the internal and the external connection of
// a port are both of user-defined nettypes (§6.6.7), the nettypes shall
// match, and the two nets are merged into one. volt_t and amp_t are two
// nettypes of the same data type real, but they are different nettypes,
// so the net n of type amp_t cannot be connected to the port of type
// volt_t; a net of type volt_t could.
// Icarus Verilog 13.0 and Verilator 5.052 do not support user-defined
// nettypes and stop at the nettype declaration.

package port_different_nettypes_pkg;
  nettype real volt_t;
  nettype real amp_t;
endpackage

module port_different_nettypes_m
  import port_different_nettypes_pkg::*;
  (input volt_t v);
endmodule

module test_illegal_port_connection_different_nettypes;
  import port_different_nettypes_pkg::*;
  amp_t n;
  port_different_nettypes_m u(n);   // illegal
endmodule
