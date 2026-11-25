/*
:name: test_randsequence_ungenerated_result_observation
:description: A production result is checked after generation and observed before generation
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_ungenerated_result_observation.expected
*/
module test_randsequence_ungenerated_result_observation;
  initial begin
    randsequence (main)
      main :
`ifdef OBSERVE_UNGENERATED
             { $display("before generation=%0d", next_value); }
`endif
             next_value { $display("after generation=%0d", next_value); };
      int next_value : { return 27; };
    endsequence
    $finish(0);
  end
endmodule
