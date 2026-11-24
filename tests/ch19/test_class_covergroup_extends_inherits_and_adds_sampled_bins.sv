/*
:name: test_class_covergroup_extends_inherits_and_adds_sampled_bins
:description: A derived class covergroup extends a base group and reports inherited and additional points
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.4.1 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_covergroup_extends_inherits_and_adds_sampled_bins.expected
*/
module test_class_covergroup_extends_inherits_and_adds_sampled_bins;
  class recorder_base;
    int sample_value;
    covergroup recorder;
      base_values: coverpoint sample_value { bins seen = {2}; }
    endgroup
    function new;
      recorder = new;
    endfunction
    function void record_sample(int value);
      sample_value = value;
      recorder.sample();
    endfunction
  endclass
  class recorder_derived extends recorder_base;
    covergroup extends recorder;
      derived_values: coverpoint sample_value { bins seen = {3}; }
    endgroup
    function new;
      super.new;
    endfunction
  endclass

  initial begin
    recorder_derived log;
    log = new;
    log.record_sample(2);
    $display("first=%.0f/%.0f", log.recorder.base_values.get_inst_coverage(),
             log.recorder.derived_values.get_inst_coverage());
    log.record_sample(3);
    $display("second=%.0f/%.0f", log.recorder.base_values.get_inst_coverage(),
             log.recorder.derived_values.get_inst_coverage());
  end
endmodule
