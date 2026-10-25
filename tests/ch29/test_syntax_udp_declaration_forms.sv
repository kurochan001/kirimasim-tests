/*
:name: test_syntax_udp_declaration_forms
:description: UDPs declared with non-ANSI headers and port declarations (output, input lists, reg, output reg with an initial value, with attributes) and with ANSI headers, with and without an end label (IEEE 1800-2023 Section 29.3)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3 29.3.1 29.3.2 29.3.4 29.7 A.5.1 A.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_udp_declaration_forms.expected
*/
// IEEE 1800-2023 §29.3.1, A.5.1: a UDP header has optional attributes, the
// keyword primitive, the name and either a list of port names (non-ANSI,
// followed by one or more port declarations) or a list of port declarations
// (ANSI); the body follows, then endprimitive with an optional label.
// A.5.2, §29.3.2: the port list has one output and one or more inputs; a
// port declaration is an output (output name, or output reg name with an
// optional initial value), an input with a list of names, or a reg, each
// with optional attributes. §29.3.4: the input fields of a table row follow
// the order of the port list, not that of the input declarations.
//
// u_mux lists (y, s, a, b) but declares b before a and s; its table selects
// a when s is 0 and b when s is 1, so reading the fields in declaration order
// would change y for s=1 a=1 b=0 and s=0 a=1 b=1. u_inv has one input. The
// latches u_lat (reg declaration), u_set (output reg q = 1'b1) and u_alat
// (ANSI, output reg q = 1'b0) hold while en is 0, so u_set and u_alat start
// at 1 and 0; then all three load d while en is 1 and keep it after en
// returns to 0.

(* kind = "comb" *) (* order = 1 *) primitive u_mux (y, s, a, b);
  (* port = "out" *) output y;
  input b;
  (* port = "in" *) input a, s;
  table
  // s a b : y
     0 0 ? : 0;
     0 1 ? : 1;
     1 ? 0 : 0;
     1 ? 1 : 1;
  endtable
endprimitive : u_mux

primitive u_inv (y, a);
  output y;
  input a;
  table
     0 : 1;
     1 : 0;
  endtable
endprimitive

(* kind = "ansi" *) primitive u_and (output y, input a, input b);
  table
     1 1 : 1;
     0 ? : 0;
     ? 0 : 0;
  endtable
endprimitive : u_and

primitive u_lat (q, en, d);
  output q;
  (* r *) reg q;
  input en, d;
  table
  // en d : q : q+
     1  0 : ? : 0;
     1  1 : ? : 1;
     0  ? : ? : -;
  endtable
endprimitive : u_lat

primitive u_set (q, en, d);
  output reg q = 1'b1;
  input en, d;
  table
     1  0 : ? : 0;
     1  1 : ? : 1;
     0  ? : ? : -;
  endtable
endprimitive

primitive u_alat (output reg q = 1'b0, input en, d);
  table
     1  0 : ? : 0;
     1  1 : ? : 1;
     0  ? : ? : -;
  endtable
endprimitive : u_alat

module test_syntax_udp_declaration_forms;
  reg s, a, b, en, d;
  wire y_mux, y_inv, y_and, q_lat, q_set, q_alat;

  u_mux  m (y_mux, s, a, b);
  u_inv  i (y_inv, a);
  u_and  g (y_and, a, b);
  u_lat  l1 (q_lat, en, d);
  u_set  l2 (q_set, en, d);
  u_alat l3 (q_alat, en, d);

  initial begin
    en = 0; d = 1;
    s = 1; a = 1; b = 0;
    #1 $display("sab=%b%b%b mux=%b inv=%b and=%b", s, a, b, y_mux, y_inv, y_and);
    s = 0; b = 1;
    #1 $display("sab=%b%b%b mux=%b inv=%b and=%b", s, a, b, y_mux, y_inv, y_and);
    s = 1; a = 0;
    #1 $display("sab=%b%b%b mux=%b inv=%b and=%b", s, a, b, y_mux, y_inv, y_and);
    $display("initial: set=%b alat=%b", q_set, q_alat);
    en = 1;
    #1 $display("load 1: lat=%b set=%b alat=%b", q_lat, q_set, q_alat);
    d = 0;
    #1 $display("load 0: lat=%b set=%b alat=%b", q_lat, q_set, q_alat);
    en = 0;
    #1 d = 1;
    #1 $display("hold: lat=%b set=%b alat=%b", q_lat, q_set, q_alat);
  end
endmodule
