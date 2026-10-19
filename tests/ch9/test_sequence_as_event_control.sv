/*
:name: test_sequence_as_event_control
:description: A named sequence used as an event control resumes the process at the end of a match (IEEE 1800-2023 Section 9.4.2.4)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2.4 16.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_as_event_control.expected
*/
// IEEE 1800-2023 §9.4.2.4: a sequence (16.8) can be used as an event
// control, written @seq or @(seq). The process resumes when the sequence
// reaches the end of a match, at the clock tick of its last element: here a
// is high at the tick at 10, b at 30 and c at 50, so the three-cycle
// sequence ends at 50 and the one-cycle sequence on a at 10.

module test_sequence_as_event_control;
  logic a = 0, b = 0, c = 0, clk = 0;

  sequence seq3;
    @(posedge clk) a ##1 b ##1 c;
  endsequence

  sequence seq1;
    @(posedge clk) a;
  endsequence

  initial begin
    @seq3;
    $display("t=%0d @seq3 resumes", $time);
  end

  initial begin
    @(seq1);
    $display("t=%0d @(seq1) resumes", $time);
  end

  initial begin
    a = 1;
    #10 clk = 1;
    #10 clk = 0;
    a = 0;
    b = 1;
    #10 clk = 1;
    #10 clk = 0;
    b = 0;
    c = 1;
    #10 clk = 1;
    #10 clk = 0;
  end
endmodule
