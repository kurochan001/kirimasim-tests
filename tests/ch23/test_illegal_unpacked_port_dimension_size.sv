/*
:name: test_illegal_unpacked_port_dimension_size
:description: Each unpacked dimension of an unpacked array port has to have the same size as the corresponding dimension of the connected array (IEEE 1800-2023 Section 23.3.3.5)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second unpacked dimension of the port p of u has size 3, and that of the connected array b has size 2
:expected_stderr_regex: test_illegal_unpacked_port_dimension_size\.sv:27:
*/
// IEEE 1800-2023 §23.3.3.5: each unpacked dimension of an unpacked array port
// shall have the same size as the corresponding dimension of the array
// connected to it. The port p is [2][3]. The instance ok connects a [0:1][3:1],
// whose dimensions have the sizes 2 and 3 with other bounds, which matches;
// u connects b [2][2], whose second dimension has size 2.

module ups_child(input logic [3:0] p [2][3]);
endmodule

module test_illegal_unpacked_port_dimension_size;
  logic [3:0] a [0:1][3:1];
  logic [3:0] b [2][2];
  ups_child ok (.p(a));
  ups_child u (.p(b));   // illegal: [2][2] for a [2][3] port
endmodule
