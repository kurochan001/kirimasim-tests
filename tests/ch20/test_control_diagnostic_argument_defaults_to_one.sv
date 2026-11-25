/*
:name: test_control_diagnostic_argument_defaults_to_one
:description: The optional diagnostic expression for stop and finish defaults to one
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_control_diagnostic_argument_defaults_to_one.expected
:expected_exit: 0
*/
`timescale 1ns/1ns
module test_control_diagnostic_argument_defaults_to_one;
  initial begin
    int level;
    bit explicit_level;
    explicit_level = $value$plusargs("level=%d", level);
    #17 $display("before control at %0d", $time);
    if ($test$plusargs("finish-control")) begin
      if (explicit_level) $finish(level);
      else $finish;
    end else begin
      if (explicit_level) $stop(level);
      else $stop;
      $display("after stop at %0d", $time);
      #3 $display("finish at %0d", $time);
      $finish(0);
    end
  end
endmodule
