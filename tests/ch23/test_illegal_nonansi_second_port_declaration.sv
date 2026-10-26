/*
:name: test_illegal_nonansi_second_port_declaration
:description: In the non-ANSI style a port that lacks a net or variable type may get one separate net declaration with the same range, but no second port declaration for the same name (IEEE 1800-2023 Section 23.2.2.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the port y is declared by the input declaration and again by the output declaration
:expected_stderr_regex: test_illegal_nonansi_second_port_declaration\.sv:(29|30):
*/
// IEEE 1800-2023 §23.2.2.1: if a port declaration does not include a net or
// variable type, the port can be declared again in a net or variable
// declaration with the same vector range, but once a name is used in a port
// declaration it shall not be declared again in another port declaration or
// in a data type declaration. The port a of ni_twice lacks the type, so its
// net declaration wire [3:0] a repeats the same range and is legal, and the
// port v takes a separate variable declaration logic [3:0] v with the same
// range; the port y is declared as input and then again as output, which is
// the second port declaration that the clause forbids.

module ni_twice (a, v, y);
  input [3:0] a;
  wire [3:0] a;
  input [3:0] v;
  logic [3:0] v;
  input [3:0] y;
  output [3:0] y;
endmodule

module test_illegal_nonansi_second_port_declaration;
  logic [3:0] a, v;
  wire [3:0] y;
  ni_twice u (a, v, y);
endmodule
