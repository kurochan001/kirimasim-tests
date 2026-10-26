/*
:name: test_sequence_repetition_and_concat_precedence
:description: consecutive [*], goto [->] and nonconsecutive [=] repetition match at their described end points, and ## binds more tightly than or, so a ##1 b or c ##1 d is (a ##1 b) or (c ##1 d) (IEEE 1800-2023 Sections 16.9.1 and 16.9.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.1 16.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_repetition_and_concat_precedence.expected
*/
// IEEE 1800-2023 §16.9.2: a[*3] matches at the end of three consecutive
// matches of a; b[->2] matches at the second match of b, with no match of b
// between the two; c[=2] matches at or after the second match of c but before
// any later match of c, so a following ##1 d pins the end point. §16.9.1,
// Table 16-1: ## has higher precedence than or, so a ##1 b or c ##1 d is
// (a ##1 b) or (c ##1 d). a and c are high at the ticks at 5, 15 and 25, b at
// 5 and 15, and d at 25 only. Thus a[*3] ends at 25, b[->2] ##1 d and
// c[=2] ##1 d end at 25, and the or matches at 15 through its left operand and
// at 25 through its right operand. If ## bound less tightly than or, the or
// would match only at 25.

`timescale 1ns/1ns

module test_sequence_repetition_and_concat_precedence;
  logic clk = 0, a = 1, b = 1, c = 1, d = 0;
  int consec[$], goto_t[$], noncon[$], or_t[$];

  always #5 clk = ~clk;   // rising edges at 5, 15, 25, ...

  c_consec: cover sequence (@(posedge clk) a[*3]) consec.push_back($time);
  c_goto: cover sequence (@(posedge clk) b[->2] ##1 d) goto_t.push_back($time);
  c_noncon: cover sequence (@(posedge clk) c[=2] ##1 d) noncon.push_back($time);
  c_or: cover sequence (@(posedge clk) a ##1 b or c ##1 d) or_t.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #20 b = 0; d = 1;
    #10 a = 0; c = 0; d = 0;
    #25;
    $display("consecutive [*3]:%s", times(consec));
    $display("goto [->2] then ##1 d:%s", times(goto_t));
    $display("nonconsecutive [=2] then ##1 d:%s", times(noncon));
    $display("or matches:%s", times(or_t));
    $finish;
  end
endmodule
