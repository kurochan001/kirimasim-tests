/*
:name: test_checker_assume_set_survives_procedural_capture
:description: A procedural checker keeps its assume set across automatic captures
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.2 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_checker_assume_set_survives_procedural_capture
:expected_stdout: @test_checker_assume_set_survives_procedural_capture.expected
*/
`timescale 1ns/1ns

checker capture_probe(input bit solve_clock, sample_clock,
                      input bit captured, input int id,
                      output bit [31:0] token,
                      output int ticks);
  rand bit [31:0] free_token = 32'h4f2e615a;
  int local_ticks = 0;
  assign token = free_token;
  assign ticks = local_ticks;

  always_ff @(posedge sample_clock) local_ticks <= local_ticks + 1;

  active_constraint: assume property (@(posedge solve_clock) free_token[0])
    $display("solve %0d t=%0d", id, $time);
  else
    $display("solve %0d t=%0d", id, $time);

  capture_constraint: assume property (@(posedge sample_clock)
    free_token[1] == captured)
    $display("sample %0d t=%0d", id, $time);
  else
    $display("sample %0d t=%0d", id, $time);
endchecker

module test_checker_assume_set_survives_procedural_capture;
  bit static_solve, static_sample, procedural_solve, procedural_sample;
  bit live_value, enable = 1;
  wire [31:0] static_token;
  bit [31:0] procedural_token;
  integer static_ticks, procedural_ticks;
  bit [31:0] before_static, before_procedural;

  capture_probe s(static_solve, static_sample, live_value, 1,
                  static_token, static_ticks);
  always @(posedge procedural_sample) begin
    automatic bit captured = live_value;
    if (enable)
      capture_probe p(procedural_solve, procedural_sample, captured, 2,
                      procedural_token, procedural_ticks);
  end

  initial begin
    #5 static_solve = 1;
    #1 before_static = static_token;
    before_procedural = procedural_token;
    #4 procedural_sample = 1;
    #1;
    $display("first keep static=%0d procedural=%0d ticks=%0d",
             static_token == before_static, procedural_token == before_procedural,
             procedural_ticks);
    #4 procedural_sample = 0;
    live_value = 1;
    enable = 0;
    #5 procedural_sample = 1;
    #1;
    $display("skipped keep procedural=%0d ticks=%0d",
             procedural_token == before_procedural, procedural_ticks);
    #4 procedural_sample = 0;
    enable = 1;
    #5 procedural_sample = 1;
    #1;
    $display("reached again keep procedural=%0d ticks=%0d",
             procedural_token == before_procedural, procedural_ticks);
    $finish;
  end
endmodule
