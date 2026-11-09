/*
:name: test_modport_expression_element_concatenation_pattern
:description: Modport expressions name an element of an unpacked array, a member of a structure, a concatenation and a typed assignment pattern of interface variables, each reached through its own port name (IEEE 1800-2023 Section 25.5.4)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5.4 10.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modport_expression_element_concatenation_pattern.expected
*/
// IEEE 1800-2023 §25.5.4: a modport expression can put an element of an
// array or a structure, a concatenation of elements or an assignment pattern
// expression of elements declared in the interface into a modport list,
// under an explicit port name that is visible only through the modport. The
// type of the port is the self-determined type of the expression, so the
// assignment pattern has its type written before it (10.9).
// The modport user of mxe_bus has
// - .elem(arr[2]), an input of the third element of an unpacked array;
// - .field(st.lo), an output of a member of a packed structure;
// - .cat({a, b}), an output of a concatenation of two 4-bit variables;
// - .pat(pair_t'{b, a}), an input of a typed assignment pattern.
// The top sets arr[2] to 8'h7e and st to 0. At 1 mxe_user writes 4'h9 to
// field, which sets st.lo only, and 8'h3c to cat, which sets a to 3 and b to
// c. At 2 it reads elem, 7e, and pat, whose hi member is b and lo member is
// a: c3. The top prints the interface variables and the values read at 3.
// Icarus Verilog 13.0 does not support modport expressions, and Verilator
// 5.052 does not support these modport expressions.

`timescale 1ns/1ns

interface mxe_bus;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } pair_t;
  logic [7:0] arr [0:3];
  pair_t st;
  logic [3:0] a, b;

  modport user (input .elem(arr[2]),
                output .field(st.lo),
                output .cat({a, b}),
                input .pat(pair_t'{b, a}));
endinterface

module mxe_user (mxe_bus.user p, output logic [7:0] seen_elem, output logic [7:0] seen_pat);
  initial begin
    #1 p.field = 4'h9;
    p.cat = 8'h3c;
    #1 seen_elem = p.elem;
    seen_pat = p.pat;
  end
endmodule

module test_modport_expression_element_concatenation_pattern;
  logic [7:0] e, q;
  mxe_bus bus ();
  mxe_user u (.p(bus), .seen_elem(e), .seen_pat(q));

  initial begin
    bus.arr[2] = 8'h7e;
    bus.st = 8'h00;
    #3 $display("st=%h a=%h b=%h elem=%h pat=%h", bus.st, bus.a, bus.b, e, q);
  end
endmodule
