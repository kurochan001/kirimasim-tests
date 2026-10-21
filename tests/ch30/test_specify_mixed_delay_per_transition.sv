/*
:name: test_specify_mixed_delay_per_transition
:description: When a module path has rise and fall delays and the gate on it has its own delays, each transition of the output takes the larger of its path delay and its gate delay (IEEE 1800-2023 Section 30.6)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.6 30.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_mixed_delay_per_transition.expected
*/
// IEEE 1800-2023 §30.6: when a module has module path delays and distributed
// delays on its primitives, the larger of the two is used for each path. A
// path with two delays has one for rising and one for falling outputs
// (30.5.1), so the comparison is made for each transition. In p the buffer
// delays both transitions by 5 and the path gives rise 2 and fall 8: the
// output rises 5 after its input (the gate is slower) and falls 8 after it
// (the path is slower). In q the buffer gives rise 6 and fall 1 and the path
// 4 for both: q rises after 6 and falls after 4. The input rises at 10 and
// falls at 30; changes before 10 are not logged.

`timescale 1ns/1ns

module test_specify_mixed_delay_per_transition_p (input a, output y);
  buf #5 (y, a);
  specify
    (a => y) = (2, 8);
  endspecify
endmodule

module test_specify_mixed_delay_per_transition_q (input a, output y);
  buf #(6, 1) (y, a);
  specify
    (a => y) = 4;
  endspecify
endmodule

module test_specify_mixed_delay_per_transition;
  reg a = 0;
  wire yp, yq;
  string log_p = "", log_q = "";

  test_specify_mixed_delay_per_transition_p up(a, yp);
  test_specify_mixed_delay_per_transition_q uq(a, yq);

  always @(yp) if ($time >= 10) log_p = {log_p, $sformatf(" %0t:%b", $time, yp)};
  always @(yq) if ($time >= 10) log_q = {log_q, $sformatf(" %0t:%b", $time, yq)};

  initial begin
    #10 a = 1;
    #20 a = 0;
    #20 $display("p:%s", log_p);
    $display("q:%s", log_q);
  end
endmodule
