/*
:name: test_active_sample_and_reactive_settling
:description: An active sample permits multiple stages while the reactive sample sees the final stage
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.7 24.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_active_sample_and_reactive_settling.expected
*/
`timescale 1ns/1ns
program observe_stable(input int stage);
  initial begin
    #1 $display("reactive t=%0d stage=%0d", $time, stage);
    #1;
  end
endprogram

module test_active_sample_and_reactive_settling;
  int stage = 0;
  int read_stage = -1;
  observe_stable reactive_reader(stage);

  task write_steps;
    #1;
    stage = 1;
    stage = 2;
  endtask

  task sample;
    #1;
    read_stage = stage;
    if ($test$plusargs("observe_active"))
      $display("active t=%0d stage=%0d", $time, read_stage);
  endtask

`ifdef READER_DECLARED_FIRST
  initial sample();
  initial write_steps();
`else
  initial write_steps();
  initial sample();
`endif
  initial begin
    #2;
    $display("allowed active sample=%0d settled stage=%0d",
             read_stage >= 0 && read_stage <= 2, stage);
    $finish(0);
  end
endmodule
