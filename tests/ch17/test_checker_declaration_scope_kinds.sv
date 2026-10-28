/*
:name: test_checker_declaration_scope_kinds
:description: A checker may be declared in a module, an interface, a program, a checker, a package, a generate block and the compilation unit, and a checker body holds every permitted declaration and item kind (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_declaration_scope_kinds.expected
*/
// IEEE 1800-2023 §17.2: Syntax 17-1 encloses an optional port list in
// checker/endchecker, allows an optional closing label, and a body of
// declarations, initial/always/final procedures, assertion items, continuous
// assignments and generate items. B006 lists the seven scopes a checker
// declaration may appear in. The test declares one checker in each scope and
// instantiates it, and each instance drives a value that the design prints at
// a fixed time: the compilation-unit checker with no port list and a closing
// label, the package checker reached through a package scope, the interface
// and program checkers, the generate-block checker, and the checker nested in
// another checker. The module-scope checker also holds a function, a let, a
// sequence, a property, a covergroup instance and a generate block. §24.3
// makes a reference to a program signal from outside every program an error,
// so the program drives the value of its checker through the output port
// hit_out and the module reads that design signal instead of p.hit. Both
// releases of the suite reject every one of these checkers, Icarus Verilog
// 13.0 as unknown syntax and Verilator 5.052 as "checker below unit-level",
// so the expected output follows the clauses alone.

`timescale 1ns/1ns

checker cu_check (input logic a, output bit y);
  assign y = a;
endchecker : cu_check

checker no_ports;
  bit state = 1'b1;
  final $display("no_ports=%b", state);
endchecker : no_ports

package pkg;
  checker pkg_check (input int v, output int got);
    assign got = v + 1;
  endchecker : pkg_check
endpackage : pkg

interface ifc;
  logic sig = 1'b1;
  bit hit;
  checker ifc_check (input logic s, output bit h);
    assign h = s;
  endchecker : ifc_check
  ifc_check ic (sig, hit);
endinterface : ifc

program prog (output bit hit_out);
  logic sig = 1'b0;
  bit hit;
  checker prog_check (input logic s, output bit h);
    assign h = ~s;
  endchecker : prog_check
  prog_check pc (.s(sig), .h(hit));
  assign hit_out = hit;
endprogram : prog

module mod;
  logic a = 1'b1;
  logic clk = 1'b0;
  bit y_cu, y_outer, y_gen, y_ifc, y_prog;
  int got;

  cu_check u_cu (.a(a), .y(y_cu));
  no_ports u_np ();

  pkg::pkg_check u_pkg (.v(4), .got(got));

  checker outer (input logic b, output bit o);
    bit inner_o;
    checker nested (input logic c, output bit d);
      assign d = c;
    endchecker : nested
    nested u_nested (.c(b), .d(inner_o));
    assign o = inner_o;
  endchecker : outer
  outer u_outer (.b(a), .o(y_outer));

  checker grammar (input logic g, output bit o);
    bit r;
    genvar gi;
    function automatic bit inv (bit x);
      return ~x;
    endfunction
    let same = (g == r);
    sequence s_one;
      @(posedge clk) g;
    endsequence
    property p_one;
      @(posedge clk) g |=> g;
    endproperty
    covergroup cg @(posedge clk);
      cp_g: coverpoint g;
    endgroup
    cg cgi = new();
    always_comb r = inv(inv(g));
    assign o = same;
    generate
      if (1) begin : gb
        bit seen;
        always_ff @(posedge clk) seen <= g;
      end
    endgenerate
  endchecker : grammar
  grammar u_grammar (.g(a), .o(y_gen));

  generate
    if (1) begin : gscope
      checker gen_check (input logic e, output bit f);
        assign f = e;
      endchecker : gen_check
      bit f;
      gen_check u_gen (.e(a), .f(f));
    end
  endgenerate
  initial begin
    #1 $display("cu=%b pkg=%0d outer=%b grammar=%b gen=%b",
                y_cu, got, y_outer, y_gen, gscope.f);
  end
endmodule : mod

module test_checker_declaration_scope_kinds;
  ifc i ();
  mod m ();
  bit prog_hit;
  prog p (.hit_out(prog_hit));

  initial begin
    #2 $display("ifc=%b prog=%b", i.hit, prog_hit);
    $finish;
  end
endmodule
