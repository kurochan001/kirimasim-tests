/*
:name: test_sequence_event_expression_clock
:description: A sequence instantiated in an event expression infers its clocking event by the sampled-value rules, here the default clocking of the procedure, so @(sq) resumes at the tick where a ##1 b ends and not at a change of a or b alone (IEEE 1800-2023 Sections 16.13.6 and 16.9.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.6 16.9.3 16.14.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_event_expression_clock.expected
*/
// IEEE 1800-2023 §16.13.6: the rules for inferring the clocking event of a
// sequence also apply to a sequence instantiated in an event expression.
// §16.9.3: outside an assertion the default clocking supplies the event when
// the procedural context has none of its own. sq = a ##1 b has no clock, so
// in always @(sq) it takes the default clocking dc at posedge clk; a is
// sampled high at the tick at 5 and b at 15, so sq ends at 15 and the event
// expression resumes there, not at the changes of a at 5 or of b at 10 or 20.
// The single recorded time 15 therefore shows that the event expression used
// the inferred clock of the sequence and not the events of its operands.

`timescale 1ns/1ns

module test_sequence_event_expression_clock;
  logic clk = 0, a = 0, b = 0;
  int ev[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25

  default clocking dc @(posedge clk);
  endclocking

  sequence sq;
    a ##1 b;
  endsequence

  always @(sq) ev.push_back(int'($time));

  initial begin
    a = 1;
    #10 a = 0; b = 1;   // 10, b is sampled high at 15
    #10 b = 0;          // 20
  end

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #40;
    $display("event:%s", times(ev));
    $finish;
  end
endmodule
