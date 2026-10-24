/*
:name: test_illegal_ansi_ref_port_of_net_type
:description: A ref port in an ANSI list of port declarations has to be of a variable type, so a ref port declared as a wire is an error (IEEE 1800-2023 Section 23.2.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ref port r of ref_net_port is declared with the net type wire
:expected_stderr_regex: test_illegal_ansi_ref_port_of_net_type\.sv:(22|27):
*/
// IEEE 1800-2023 §23.2.2.2 (footnote 2 of Syntax 23-4): a ref port shall be
// of a variable type. The port r of ref_net_port is declared ref wire. The
// instance connects a variable of the same width, which a ref port of
// type logic would legally take, so only the declaration is wrong; a tool
// can also report the error at the instance.
// Icarus Verilog 13.0 does not support ref ports and stops on the module,
// and the design is accepted by Verilator 5.052.

module ref_net_port(ref wire [3:0] r);  // illegal: a ref port is a net
endmodule

module test_illegal_ansi_ref_port_of_net_type;
  logic [3:0] v = 4'h2;
  ref_net_port u(.r(v));  // or here
endmodule
