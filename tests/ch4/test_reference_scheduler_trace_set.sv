/*
:name: test_reference_scheduler_trace_set
:description: Compare a timed race and its NBA wakeup with the traces permitted by the event scheduler
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.3 4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reference_scheduler_trace_set.expected
*/
module test_reference_scheduler_trace_set;
  timeunit 1ns;
  timeprecision 1ns;

`ifdef REVERSE_WRITERS
  localparam int FIRST_WRITER = 7, SECOND_WRITER = 3;
`else
  localparam int FIRST_WRITER = 3, SECOND_WRITER = 7;
`endif

  int winner = 0;
  int stage = 0;
  int settled = 0;

  // The ordinary run has one writer. The opt-in runs race two Active writes.
  initial begin
    if ($test$plusargs("observe_race"))
      #1 winner = FIRST_WRITER;
  end
  initial begin
    #1 winner = $test$plusargs("observe_race") ? SECOND_WRITER : 7;
  end

  always @(stage) begin
    if (stage != 0) begin
      $display("wake t=%0d stage=%0d winner=%0d settled=%0d",
               $time, stage, winner, settled);
      settled <= stage + 10;
    end
  end

  initial begin
    #1;
    #0;
    $display("inactive t=%0d winner=%0d stage=%0d", $time, winner, stage);
    stage <= winner;
    winner = 9;
    $strobe("postponed t=%0d stage=%0d winner=%0d settled=%0d",
            $time, stage, winner, settled);
    #1;
    $display("next t=%0d stage=%0d winner=%0d settled=%0d",
             $time, stage, winner, settled);
    $finish(0);
  end
endmodule
