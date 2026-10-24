/*
:name: test_cg_option_evaluated_at_new
:description: option is a member of the covergroup, each coverpoint and each cross, set in the definition with option.member = expression, and those expressions are evaluated when an instance is made, so each instance has the values of its own arguments and of the variables at its new (IEEE 1800-2023 Section 19.7)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.7 19.8 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_option_evaluated_at_new.expected
*/
// IEEE 1800-2023 §19.7: option is a built-in member of every covergroup,
// coverpoint and cross, and option.member = expression in the definition
// sets an instance option; these assignments are evaluated when the
// covergroup is instantiated, and each instance may get a different value.
//
// g1 is made with the arguments 1 and 2 while base_goal is 90, g2 with 2 and
// 3 after base_goal has become 80. So g1 has at_least 1, goal 90, a weight of
// 2 for cp and a goal of 10 for x, and g2 at_least 2, goal 80, weight 3 and
// goal 20. One sample of a = 0 covers a bin of cp in g1 but not in g2, where
// a bin needs two hits (19.11.1). get_inst_coverage(c, t) gives the covered
// bins and the bins (19.8).

module test_cg_option_evaluated_at_new;
  bit [1:0] a;
  bit b;
  int base_goal = 90;

  covergroup cg (int al, int w);
    option.at_least = al;
    option.goal = base_goal;
    cp: coverpoint a { option.weight = w; bins v[] = {[0:3]}; }
    cq: coverpoint b { bins v[] = {0, 1}; }
    x: cross cp, cq { option.goal = al * 10; }
  endgroup

  cg g1, g2;

  task automatic show(string name, cg g);
    int c, t;
    void'(g.cp.get_inst_coverage(c, t));
    $display("%s: at_least %0d, goal %0d, cp weight %0d, x goal %0d, cp %0d/%0d", name,
             g.option.at_least, g.option.goal, g.cp.option.weight, g.x.option.goal, c, t);
  endtask

  initial begin
    g1 = new(1, 2);
    base_goal = 80;
    g2 = new(2, 3);
    a = 0;
    b = 0;
    g1.sample();
    g2.sample();
    show("g1", g1);
    show("g2", g2);
  end
endmodule
