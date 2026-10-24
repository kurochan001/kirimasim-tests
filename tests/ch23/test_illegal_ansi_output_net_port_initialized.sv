/*
:name: test_illegal_ansi_output_net_port_initialized
:description: Only a variable output port in an ANSI list of port declarations can be initialized, so an output port of net type with an initial value is an error (IEEE 1800-2023 Section 23.2.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the output port y of out_net_init is a wire and is given the value 4'h5 in its declaration
:expected_stderr_regex: test_illegal_ansi_output_net_port_initialized\.sv:21:
*/
// IEEE 1800-2023 §23.2.2.2 (footnote 2 of Syntax 23-4): it shall be illegal
// to initialize a port that is not a variable output port. out_net_init
// has a variable output z with an initial value, which is legal, and a
// net output y with one, which is the error.
// The design is accepted by Verilator 5.052.

module out_net_init(output logic [3:0] z = 4'h3,
                    output wire [3:0] y = 4'h5);  // illegal: y is a net
endmodule

module test_illegal_ansi_output_net_port_initialized;
  wire [3:0] a, b;
  out_net_init u(.z(a), .y(b));
endmodule
