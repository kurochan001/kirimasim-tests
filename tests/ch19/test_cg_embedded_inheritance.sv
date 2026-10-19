/*
:name: test_cg_embedded_inheritance
:description: covergroup extends in a derived class replaces the base class's embedded covergroup with a derived one that keeps the base items, replaces a coverpoint of the same name and adds new ones, while base and derived covergroups remain separate types for get_coverage (IEEE 1800-2023 Section 19.4.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.4.1 19.4 19.11 19.11.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_embedded_inheritance.expected
*/
// IEEE 1800-2023 §19.4.1: covergroup extends cg in a derived class defines a
// derived covergroup that replaces the instance of cg, also where the base
// class refers to cg, as in its constructor. Components of the base
// covergroup belong to the derived one too, except a coverpoint replaced by
// one of the same name, which no longer contributes; new coverpoints are
// added. For get_coverage, the base and the derived covergroup are separate
// types. §19.11: the coverage of a covergroup is the average of its items
// (all weights are 1), and of a coverpoint its covered bins over its bins
// (§19.11.1). Here the base covergroup has cm (4 bins) and cf (2 automatic
// bins); the derived one replaces cm by a coverpoint with one bin and adds cg2
// (2 automatic bins). Both objects sample m = 1, f = 0 and g = 1.

module test_cg_embedded_inheritance;
  class base;
    bit [1:0] m;
    bit f;
    covergroup cg;
      cm: coverpoint m { bins m0 = {0}; bins m1 = {1}; bins m2 = {2}; bins m3 = {3}; }
      cf: coverpoint f;
    endgroup
    function new();
      cg = new;
    endfunction
    function void put(bit [1:0] vm, bit vf);
      m = vm;
      f = vf;
      cg.sample();
    endfunction
  endclass

  class derived extends base;
    bit g;
    covergroup extends cg;
      cm: coverpoint m { bins low = {[0:1]}; }
      cg2: coverpoint g;
    endgroup
    function new();
      super.new();
    endfunction
  endclass

  base b;
  derived d;

  initial begin
    b = new;
    d = new;
    d.g = 1;
    b.put(1, 0);
    d.put(1, 0);
    $display("base object: %.2f, type %.2f", b.cg.get_inst_coverage(), b.cg.get_coverage());
    $display("derived object: %.2f, type %.2f", d.cg.get_inst_coverage(), d.cg.get_coverage());
  end
endmodule
