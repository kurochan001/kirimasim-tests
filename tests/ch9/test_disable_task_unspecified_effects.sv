/*
:name: test_disable_task_unspecified_effects
:description: Observe output arguments and pending assignments when a task is disabled
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_task_unspecified_effects.expected
*/
`timescale 1ns/1ns
module test_disable_task_unspecified_effects;
  bit cancel;
  int out_value = 7, io_value = 9;
  logic pending = 0;
  logic procedural_drive = 0;
  wire forced = 1'b0;

  task worker(output int outgoing, inout int exchange);
    outgoing = 30;
    exchange = 41;
    pending <= #5 1;
    assign procedural_drive = 1'b1;
    force forced = 1'b1;
    #2;
    if (cancel) begin
      $display("disabling task at t=%0d", $time);
      disable worker;
    end
    deassign procedural_drive;
    procedural_drive = 0;
    release forced;
  endtask

  initial begin
    cancel = $test$plusargs("observe_disabled");
    fork
      begin
        worker(out_value, io_value);
        $display("return time=%0d", $time);
      end
      begin
        #1;
        $display("entry t=%0d pending=%b driven=%b forced=%b",
                 $time, pending, procedural_drive, forced);
        #5;
        $display("complete t=%0d output=%0d inout=%0d nba=%b assigned=%b forced=%b",
                 $time, out_value, io_value, pending, procedural_drive, forced);
      end
    join
    $finish(0);
  end
endmodule
