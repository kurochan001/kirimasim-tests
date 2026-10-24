/*
:name: test_illegal_ansi_inout_port_of_variable_type
:description: An inout port in an ANSI list of port declarations cannot be of a variable type, so an inout port declared with var logic is an error (IEEE 1800-2023 Section 23.2.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the inout port io of inout_var_port is declared with var, which makes it a variable
:expected_stderr_regex: test_illegal_ansi_inout_port_of_variable_type\.sv:(22|28):
*/
// IEEE 1800-2023 §23.2.2.2 (footnote 2 of Syntax 23-4): an inout port shall
// not be of a variable type. The port io of inout_var_port is declared
// inout var logic, a variable; the port b, inout logic without var, is a
// net (23.2.2.3) and legal. The instance connects nets to both ports, so
// only the declaration of io is wrong; a tool can also report the error
// at the instance.
// The design is accepted by Verilator 5.052.

module inout_var_port(inout var logic [3:0] io, inout logic b);  // illegal: io
endmodule

module test_illegal_ansi_inout_port_of_variable_type;
  wire [3:0] w;
  wire x;
  inout_var_port u(.io(w), .b(x));  // or here
endmodule
