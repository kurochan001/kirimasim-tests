/*
:name: test_port_redeclared_as_net_or_variable
:description: a port whose declaration has no net or variable type can be declared again as a net or a variable of the same name in a module, an interface, a program or a primitive, and that declaration gives the port its kind and signedness (IEEE 1800-2023 Section 3.13)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.13 23.2.2.1
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_redeclared_as_net_or_variable.expected
*/
// IEEE 1800-2023 §3.13 g): a port name of the port name space can be
// declared again in the module name space as a variable or a net of the
// same name. §23.2.2.1: this is allowed when the port declaration has no net
// or variable type; the ranges of the two declarations are the same, and
// when either declaration is signed, both are. §29.3: the output of a
// primitive declared again as reg makes the primitive sequential, so it
// keeps its state when no table entry changes it.
//   - rd_mod declares input [7:0] a and then wire signed [7:0] a, so a is a
//     signed net: 8'hf0 prints as -16 and a < 0 is 1. It declares output
//     [7:0] q and then logic [7:0] q, so q is a variable that the procedure
//     assigns: a >>> 1 is an arithmetic shift of a signed value, 8'hf8.
//   - rd_if and rd_prog declare a 4-bit input again as a signed net and an
//     8-bit output again as a variable, which their procedures set to the
//     input: the value is sign-extended, 4'b1010 to 8'hfa and 4'b1001 to
//     8'hf9.
//   - rd_latch declares output q and then reg q: while en is 1 q follows d,
//     and while en is 0 it keeps its value when d changes.
// The program waits until 13, so the simulation ends after the last line.

primitive rd_latch(q, en, d);
  output q;
  reg q;
  input en, d;
  table
  // en d : q : q+
     1  0 : ? : 0;
     1  1 : ? : 1;
     0  ? : ? : -;
  endtable
endprimitive

module rd_mod(a, q);
  input [7:0] a;
  wire signed [7:0] a;
  output [7:0] q;
  logic [7:0] q;
  initial begin
    #1 $display("module: a=%0d negative=%0d", a, a < 0);
    q = a >>> 1;
  end
endmodule

interface rd_if(n, v);
  input [3:0] n;
  wire signed [3:0] n;
  output [7:0] v;
  logic [7:0] v;
  initial #2 v = n;
endinterface

program rd_prog(pn, pv);
  input [3:0] pn;
  wire signed [3:0] pn;
  output [7:0] pv;
  logic [7:0] pv;
  initial begin
    #3 pv = pn;
    #10;
  end
endprogram

module test_port_redeclared_as_net_or_variable;
  logic [7:0] a_src = 8'hf0;
  logic [3:0] n_src = 4'b1010, pn_src = 4'b1001;
  wire [7:0] q_mod, v_if, v_prog;
  logic en = 1'b0, d = 1'b0;
  wire lq;

  rd_mod u_mod(a_src, q_mod);
  rd_if u_if(n_src, v_if);
  rd_prog u_prog(pn_src, v_prog);
  rd_latch u_latch(lq, en, d);

  initial begin
    #4 $display("outputs: module q=%h interface v=%h program v=%h", q_mod, v_if, v_prog);
    en = 1'b1;
    d = 1'b1;
    #1 $display("latch open: q=%b", lq);
    en = 1'b0;
    #1 d = 1'b0;
    #1 $display("latch closed: q=%b", lq);
    en = 1'b1;
    #1 $display("latch open again: q=%b", lq);
  end
endmodule
