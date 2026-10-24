/*
:name: test_cg_declaration_contexts
:description: A covergroup is a type that can be declared in a package, a module, a program, an interface, a checker and a class, with formal arguments, options, coverpoints and crosses, and new makes any number of independent instances of it (IEEE 1800-2023 Section 19.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.3 19.4 17.6 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_declaration_contexts.expected
*/
// IEEE 1800-2023 §19.3: a covergroup is a user-defined type that may have a
// coverage event, formal arguments, options, coverpoints and crosses; new
// creates instances of it, as many as wanted, and a covergroup can be defined
// in a package, module, program, interface, checker or class (19.4 for a
// class, 17.6 for a checker). Each coverpoint below has a bin for each of its
// values, and the coverage of a coverpoint is the share of its bins covered.
//
// The module covergroup has the argument lo, which sets the bins of cp to
// lo..3, and three instances of it, sampled once with v = 3 and w = 1: cp
// has 4, 2 and 1 bins and the cross has 8, 4 and 2. The package covergroup
// samples 1, the interface covergroup 2 and 0, the class covergroup 0 to 3,
// the program covergroup 0, 1 and 2 at 20, and the checker covergroup v = 3
// at the rising edge of clk. When the program's initial procedure ends, the
// simulation ends (24.3), and the final procedure of the checker prints last.

package cg_pkg;
  covergroup pkg_cg with function sample(int x);
    cp: coverpoint x { bins b[] = {[0:3]}; }
  endgroup
endpackage

interface cg_bus;
  int x;
  covergroup bus_cg;
    cp: coverpoint x { bins b[] = {[0:3]}; }
  endgroup
  bus_cg inst = new;
endinterface

checker cg_chk(logic clk, int x);
  covergroup chk_cg @(posedge clk);
    cp: coverpoint x { bins b[] = {[0:3]}; }
  endgroup
  chk_cg inst = new();
  final $display("checker: %.2f", inst.cp.get_inst_coverage());
endchecker

class cg_cls;
  int x;
  covergroup cls_cg;
    cp: coverpoint x { bins b[] = {[0:3]}; }
  endgroup
  function new();
    cls_cg = new;
  endfunction
  function void put(int val);
    x = val;
    cls_cg.sample();
  endfunction
endclass

program cg_prog;
  int x;
  covergroup prog_cg;
    cp: coverpoint x { bins b[] = {[0:3]}; }
  endgroup
  prog_cg inst = new;
  initial begin
    #20;
    for (int i = 0; i < 3; i++) begin
      x = i;
      inst.sample();
    end
    $display("program: %.2f", inst.cp.get_inst_coverage());
  end
endprogram

module test_cg_declaration_contexts;
  logic clk = 0;
  int v = 3;
  bit w = 1;
  event e;

  covergroup mod_cg (int lo) @(e);
    option.at_least = 1;
    cp: coverpoint v { bins b[] = {[lo:3]}; }
    cw: coverpoint w;
    x: cross cp, cw;
  endgroup

  mod_cg m1 = new(0);
  mod_cg m2 = new(2);
  mod_cg m3 = new(3);
  cg_pkg::pkg_cg p = new;
  cg_cls c;

  cg_bus bus();
  cg_chk chk(clk, v);

  task automatic show(string name, mod_cg m);
    int xc, xt;
    void'(m.x.get_inst_coverage(xc, xt));
    $display("module %s: cp %.2f, cross %0d/%0d", name, m.cp.get_inst_coverage(), xc, xt);
  endtask

  initial begin
    #1 clk = 1;
    #1 -> e;
    show("m1", m1);
    show("m2", m2);
    show("m3", m3);
    p.sample(1);
    $display("package: %.2f", p.cp.get_inst_coverage());
    bus.x = 2;
    bus.inst.sample();
    bus.x = 0;
    bus.inst.sample();
    $display("interface: %.2f", bus.inst.cp.get_inst_coverage());
    c = new;
    for (int i = 0; i < 4; i++) c.put(i);
    $display("class: %.2f", c.cls_cg.cp.get_inst_coverage());
  end
endmodule
