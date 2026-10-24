/*
:name: test_cg_constructor_arguments
:description: The actual arguments of a covergroup constructor are evaluated when new runs; an input argument keeps that value, a ref argument follows later changes of its actual, and a defaulted argument may be left out (IEEE 1800-2023 Section 19.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_constructor_arguments.expected
*/
// IEEE 1800-2023 §19.3: new of a covergroup with formal arguments takes all
// the actual arguments that are not defaulted; the actuals are evaluated when
// new is executed. An input argument only has the value passed at that time,
// while a ref argument tracks the value of its actual as it changes.
//
// The instance is made with new(a + 10, r), when a is 1 and r is 0, and the
// defaulted argument d is left out, so it is 4. Then a becomes 2 and r
// becomes 3, and the covergroup is sampled with v = 0. Each coverpoint has
// one bin for one value, so its coverage is 100 when that value was sampled
// and 0 otherwise: v + k is 11, not 12; rv is 3, not 0; v + d is 4.

module test_cg_constructor_arguments;
  int a = 1;
  int r = 0;
  int v = 0;

  covergroup cg (input int k, ref int rv, input int d = 4);
    k_11: coverpoint (v + k) { bins b = {11}; }
    k_12: coverpoint (v + k) { bins b = {12}; }
    r_0: coverpoint rv { bins b = {0}; }
    r_3: coverpoint rv { bins b = {3}; }
    d_4: coverpoint (v + d) { bins b = {4}; }
  endgroup

  cg g;

  initial begin
    g = new(a + 10, r);
    a = 2;
    r = 3;
    g.sample();
    $display("input k: 11 %.0f, 12 %.0f", g.k_11.get_inst_coverage(),
             g.k_12.get_inst_coverage());
    $display("ref rv: 0 %.0f, 3 %.0f", g.r_0.get_inst_coverage(), g.r_3.get_inst_coverage());
    $display("default d: 4 %.0f", g.d_4.get_inst_coverage());
  end
endmodule
