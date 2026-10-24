/*
:name: test_illegal_inout_port_connected_to_variable
:description: An inout port of a built-in net type can be connected to a net, a concatenation of nets or nothing, but not to a variable (IEEE 1800-2023 Section 23.3.3.3)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.3 23.3.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the inout port p of u is connected to the variable v
:expected_stderr_regex: test_illegal_inout_port_connected_to_variable\.sv:32:
*/
// IEEE 1800-2023 §23.3.3.3: an inout port declared as a wire can be connected
// to a net or a concatenation of nets of a compatible type, or left
// unconnected, but it cannot be connected to a variable; 23.3.3.2 also says a
// variable is not permitted on either side of an inout port. The instances
// to_net, to_concat and open use the three legal forms; u connects the
// variable v from outside.
// Oracle checks: the 5.052 release of Verilator accepts the design.

module vic_child(inout wire [1:0] p);
endmodule

module test_illegal_inout_port_connected_to_variable;
  wire [1:0] n;
  wire hi, lo;
  logic [1:0] v;
  vic_child to_net (.p(n));
  vic_child to_concat (.p({hi, lo}));
  vic_child open (.p());
  vic_child u (.p(v));   // illegal: v is a variable
endmodule
