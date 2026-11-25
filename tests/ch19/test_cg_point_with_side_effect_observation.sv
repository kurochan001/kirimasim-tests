/*
:name: test_cg_point_with_side_effect_observation
:description: Observe a coverpoint filter that changes state alongside a pure filter
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_point_with_side_effect_observation.expected
*/
module test_cg_point_with_side_effect_observation;
  bit [1:0] sampled;

  covergroup pure_group;
    point: coverpoint sampled { bins chosen[] = {[0:3]} with (item % 2 == 0); }
  endgroup
  pure_group control;

`ifdef OBSERVE_BIN_EFFECTS
  int evaluations = 0;
  covergroup effect_group;
    point: coverpoint sampled { bins chosen[] = {[0:3]} with ((evaluations++ & 1) == 0); }
  endgroup
  effect_group observed;
`endif

  initial begin
    control = new;
    sampled = 0;
    control.sample();
    $display("pure point=%0.0f", control.point.get_inst_coverage());

`ifdef OBSERVE_BIN_EFFECTS
    observed = new;
    observed.sample();
    $display("effect point=%0.0f evaluations=%0d", observed.point.get_inst_coverage(), evaluations);
`endif
  end
endmodule
