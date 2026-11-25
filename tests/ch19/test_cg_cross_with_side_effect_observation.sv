/*
:name: test_cg_cross_with_side_effect_observation
:description: Observe a cross filter that changes state with pure constituent coverpoints
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6.1.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_with_side_effect_observation.expected
*/
module test_cg_cross_with_side_effect_observation;
  bit [1:0] a, b;

  covergroup pure_group;
    p: coverpoint a { bins chosen[] = {[0:3]} with (item % 2 == 0); }
    q: coverpoint b;
    c: cross p, q { bins selected = c with (p == q); }
  endgroup
  pure_group control;

`ifdef OBSERVE_BIN_EFFECTS
  int evaluations = 0;
  covergroup effect_group;
    p: coverpoint a { bins chosen[] = {[0:3]} with (item % 2 == 0); }
    q: coverpoint b;
    c: cross p, q { bins selected = c with ((evaluations++ & 1) == 0); }
  endgroup
  effect_group observed;
`endif

  initial begin
    control = new;
    a = 0;
    b = 0;
    control.sample();
    $display("pure point=%0.0f cross=%0.0f",
             control.p.get_inst_coverage(), control.c.get_inst_coverage());

`ifdef OBSERVE_BIN_EFFECTS
    observed = new;
    observed.sample();
    $display("effect cross=%0.0f evaluations=%0d", observed.c.get_inst_coverage(), evaluations);
`endif
  end
endmodule
