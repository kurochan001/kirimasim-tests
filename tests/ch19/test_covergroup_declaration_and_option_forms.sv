/*
:name: test_covergroup_declaration_and_option_forms
:description: A covergroup has optional ports, a clocking event or a sample method, coverage options set from an expression and type options set from a constant, coverpoints with a typed label, an iff guard and a body or a lone semicolon, an end label, and the extends form in a derived class (IEEE 1800-2023 Sections 19.3, 19.4.1, 19.5 and 19.7.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.3 19.4.1 19.5 19.7.1 A.2.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_covergroup_declaration_and_option_forms.expected
*/
// IEEE 1800-2023 §19.2 with A.2.11: a covergroup declaration has a name,
// optional ports, an optional coverage event, coverage specifications and
// options, and endgroup with an optional label. The coverage event is a
// clocking event or a sample method (§19.3). A coverage option is set from
// any expression and a type option from a constant expression (§19.7.1). A
// coverpoint may have a type and a label, an iff guard and a bins body or a
// lone semicolon (§19.5). §19.4.1 adds the extends form, which defines a
// derived covergroup in a derived class and keeps the base items.
//
// cg_m has two ports, a clocking event, an option set from the note port, two
// type options, a typed coverpoint with an iff guard and two bins, and a bare
// coverpoint whose body is one semicolon. Sampled at v = 1, 2 and 3, the
// guard admits all three, so one and two are both covered, and the bare
// coverpoint covers one of its two automatic bins, so the group coverage is
// the average 75. The class
// covergroup cg has a sample method; the derived covergroup keeps cp and adds
// extra. Sampling 1 covers cp.a in both, and v = 3 covers extra.c, so the
// base group is at 50 and the derived group at 75.

module test_covergroup_declaration_and_option_forms;
  logic clk = 0;
  int v = 0;
  bit bv = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  covergroup cg_m (int lo, string note) @(posedge clk);
    option.per_instance = 1;
    option.comment = note;
    type_option.comment = "module covergroup";
    type_option.weight = 2;
    int cp: coverpoint v iff (v >= lo) {
      option.weight = 1;
      bins one = {1};
      bins two = {2};
    }
    bare: coverpoint bv;
  endgroup : cg_m

  class holder;
    int v;
    covergroup cg with function sample(int x);
      cp: coverpoint x { bins a = {1}; bins b = {2}; }
    endgroup : cg
    function new();
      cg = new;
    endfunction
  endclass

  class derived extends holder;
    covergroup extends cg;
      extra: coverpoint v { bins c = {3}; }
    endgroup
    function new();
      super.new();
    endfunction
  endclass

  cg_m g = new(1, "values");

  initial begin
    holder h;
    derived d;
    #3 v = 1; bv = 1;
    #10 v = 2;
    #10 v = 3;
    #5 $display("module covergroup %0.0f", g.get_inst_coverage());
    h = new;
    d = new;
    h.cg.sample(1);
    d.v = 3;
    d.cg.sample(1);
    $display("base class %0.0f", h.cg.get_inst_coverage());
    $display("derived class %0.0f", d.cg.get_inst_coverage());
    $finish;
  end
endmodule
