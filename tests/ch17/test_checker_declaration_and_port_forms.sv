/*
:name: test_checker_declaration_and_port_forms
:description: A checker declaration with no parentheses, with empty parentheses, and with a port list whose items carry attributes, an explicit or an inherited direction, a property formal type, variable dimensions and a default actual, and endchecker with and without its name (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.2 A.1.2 A.1.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_declaration_and_port_forms.expected
*/
// IEEE 1800-2023 17.2, A.1.2 and A.1.8: checker_declaration is checker, an
// identifier, an optional parenthesized optional checker_port_list,
// a semicolon, optionally attributed checker_or_generate_items, endchecker
// and an optional colon and name. A checker_port_list is one or more
// comma-separated checker_port_items, and an item is optional attributes,
// an optional input or output, a property formal type, an identifier, zero or
// more variable dimensions and an optional default actual.
//   - ck_none has no parentheses and sets the compilation-unit variable
//     none_n from an initial item that carries an attribute,
//   - ck_empty has empty parentheses and the end name, and sets empty_n,
//   - ck_ports has an attributed input vector, an input whose type is given,
//     an input whose direction is omitted and therefore inherited, an input
//     array of two ints, an output int, and an output int with the default
//     (initial) value 5 that its initial item raises to 6.
// y is a + b + c + vec[0] + vec[1] = 2 + 1 + 1 + 1 + 1 = 6.
//
// Icarus Verilog 13.0 has no checkers. Verilator 5.052 does not accept a
// default value on a checker port.

int none_n;
int empty_n;

checker ck_none;
  (* keep *) initial none_n = 1;
endchecker

checker ck_empty ();
  initial empty_n = 2;
endchecker : ck_empty

checker ck_ports (
  (* keep *) input logic [3:0] a,
  input logic b,
  logic c,
  input int vec [2],
  output int y,
  output int y2 = 5
);
  always_comb y = a + b + c + vec[0] + vec[1];
  initial y2 = y2 + 1;
endchecker : ck_ports

module test_checker_declaration_and_port_forms;
  logic [3:0] a = 4'd2;
  logic b = 1'b1;
  logic c = 1'b1;
  int vec [2];
  int y, y2;

  ck_none u_none ();
  ck_empty u_empty ();
  ck_ports u_ports (.a(a), .b(b), .c(c), .vec(vec), .y(y), .y2(y2));

  initial begin
    vec[0] = 1;
    vec[1] = 1;
    #1 $display("ports: y=%0d y2=%0d", y, y2);
    $display("none=%0d empty=%0d", none_n, empty_n);
  end
endmodule
