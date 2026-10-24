/*
:name: test_illegal_nonansi_variable_port_redeclared
:description: A non-ANSI port declaration that includes a variable type declares the port completely, so declaring the port again in a variable declaration, here to add a range, is an error (IEEE 1800-2023 Section 23.2.2.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the port q is declared as output reg, which includes a variable type, and is declared again by the variable declaration reg [3:0] q
:expected_stderr_regex: test_illegal_nonansi_variable_port_redeclared\.sv:26:
*/
// IEEE 1800-2023 §23.2.2.1: if a port declaration includes a net or
// variable type, the port is completely declared, and declaring it again
// in a net or variable declaration is an error; so the range and the
// signedness have to be in the port declaration itself. The output q of
// nonansi_var_redeclared is declared with the variable type reg and then
// again as a 4-bit reg. The output r, declared without a type, legally
// gets its variable declaration separately.

module nonansi_var_redeclared(d, q, r);
  input [3:0] d;
  output reg q;
  output [3:0] r;
  reg [3:0] q;  // illegal: q is already completely declared
  reg [3:0] r;
  always @* begin
    q = d;
    r = ~d;
  end
endmodule

module test_illegal_nonansi_variable_port_redeclared;
  wire [3:0] d = 4'h6;
  wire [3:0] q, r;
  nonansi_var_redeclared u(d, q, r);
endmodule
