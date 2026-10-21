/*
:name: test_randsequence_weights
:description: In randsequence, an alternative with weight 0 is never generated, an alternative without a weight has weight 1, and a weight is evaluated each time its production is selected (IEEE 1800-2023 Section 18.17.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17.1 18.17 18.17.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_weights.expected
*/
// IEEE 1800-2023 §18.17.1: an alternative is generated with a probability in
// proportion to its weight, and one without a weight has weight 1. So in
// pick_a the alternative of weight 0 can never be chosen, and in pick_b the
// alternative without a weight always wins over one of weight 0. The weights
// of pick_c are evaluated each time pick_c is selected, so after the code
// block of the first rule sets w to 0, only the second rule can follow. A
// weight that is an expression is written in parentheses (Syntax 18-14).

module test_randsequence_weights;
  string log = "";
  int w = 1;

  initial begin
    randsequence (main)
      main   : repeat (5) pick_a sep repeat (5) pick_b sep repeat (5) pick_c;
      pick_a : a := 0 | b := 3;
      pick_b : c | d := 0;
      pick_c : e := w { w = 0; } | f := (1 - w);
      sep    : { log = {log, "/"}; };
      a      : { log = {log, "a"}; };
      b      : { log = {log, "b"}; };
      c      : { log = {log, "c"}; };
      d      : { log = {log, "d"}; };
      e      : { log = {log, "e"}; };
      f      : { log = {log, "f"}; };
    endsequence
    $display("%s", log);
  end
endmodule
