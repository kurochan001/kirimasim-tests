/*
:name: test_illegal_port_connection_nettype_data_type_mismatch
:description: When only one side of a port connection is a net of a user-defined nettype, the data types of both sides have to match (IEEE 1800-2023 Section 23.3.3)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the port of the real nettype volt_t is connected to a logic vector variable, whose data type does not match real
:expected_stderr_regex: test_illegal_port_connection_nettype_data_type_mismatch\.sv:34:
*/
// IEEE 1800-2023 §23.3.3: if only one of the two connections of a port is
// of a user-defined nettype (§6.6.7), the connections shall have matching
// data types, the port shall be an input or output, and the connection is
// a continuous assignment from source to sink. The input port v has the
// nettype volt_t of data type real, and u connects the logic [7:0]
// variable q; a real variable would match.
// Icarus Verilog 13.0 and Verilator 5.052 do not support user-defined
// nettypes and stop at the nettype declaration.

package port_nettype_mismatch_pkg;
  nettype real volt_t;
endpackage

module port_nettype_mismatch_m
  import port_nettype_mismatch_pkg::*;
  (input volt_t v);
endmodule

module test_illegal_port_connection_nettype_data_type_mismatch;
  logic [7:0] q = 8'd3;
  port_nettype_mismatch_m u(q);   // illegal
endmodule
