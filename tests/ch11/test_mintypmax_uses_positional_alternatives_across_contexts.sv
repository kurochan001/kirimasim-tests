/*
:name: test_mintypmax_uses_positional_alternatives_across_contexts
:description: Nonmonotonic min typ max alternatives select the same position in a parameter, procedural delay, net delay, and specify path
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.11 9.4.1 10.3.3 30.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mintypmax_uses_positional_alternatives_across_contexts.expected
*/
`timescale 1ns/1ns
module positional_path(input wire source, output wire changed);
  buf g(changed, source);
  specify
    (source => changed) = (17:3:12);
  endspecify
endmodule

module test_mintypmax_uses_positional_alternatives_across_contexts;
  localparam int CHOICE = (13:5:9);
  bit stimulus;
  wire #(21:8:11) net_delay = stimulus;
  wire path_delay;
  positional_path dut(stimulus, path_delay);
  time launched, procedural_elapsed, net_elapsed = 0, path_elapsed = 0;

  always @(posedge net_delay) net_elapsed = $time - launched;
  always @(posedge path_delay) path_elapsed = $time - launched;

  initial begin
    #30;
    launched = $time;
    stimulus = 1;
    #(7:4:19) procedural_elapsed = $time - launched;
    #25;
    if ($test$plusargs("record_selection"))
      $display("choice=%0d procedural=%0d net=%0d path=%0d",
               CHOICE, procedural_elapsed, net_elapsed, path_elapsed);
    $display("consistent=%0d",
             (CHOICE == 13 && procedural_elapsed == 7 && net_elapsed == 21 && path_elapsed == 17) ||
             (CHOICE == 5 && procedural_elapsed == 4 && net_elapsed == 8 && path_elapsed == 3) ||
             (CHOICE == 9 && procedural_elapsed == 19 && net_elapsed == 11 && path_elapsed == 12));
    $finish(0);
  end
endmodule
