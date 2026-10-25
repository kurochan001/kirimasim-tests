/*
:name: test_illegal_inout_port_nettype_one_side
:description: When only one side of a port connection is a net of a user-defined nettype, the port has to be an input or an output, so it cannot be an inout (IEEE 1800-2023 Section 23.3.3)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the inout port v, a wire of data type logic [3:0], is connected to a net of the nettype lnet_t, so only one side is of a user-defined nettype and the port is an inout
:expected_stderr_regex: test_illegal_inout_port_nettype_one_side\.sv:33:
*/
// IEEE 1800-2023 §23.3.3: if only one of the two connections of a port is
// of a user-defined nettype (§6.6.7), the data types shall match and the
// port shall be of mode input or output. The net n has the nettype
// lnet_t of data type logic [3:0], and the port v is an inout wire of the
// same data type logic [3:0], which is not of a nettype; the data types
// match, but the port is an inout. As an input the port would be legal.
// Icarus Verilog 13.0 and Verilator 5.052 do not support user-defined
// nettypes and stop at the nettype declaration.

package inout_nettype_one_side_pkg;
  nettype logic [3:0] lnet_t;
endpackage

module inout_nettype_one_side_m(inout wire logic [3:0] v);
endmodule

module test_illegal_inout_port_nettype_one_side;
  import inout_nettype_one_side_pkg::*;
  lnet_t n;
  inout_nettype_one_side_m u(n);   // illegal
endmodule
