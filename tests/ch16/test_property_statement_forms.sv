/*
:name: test_property_statement_forms
:description: A labeled assert with pass and else actions, an assume with an action, cover property with a statement and with a null statement, cover sequence with a clocking event and disable iff, restrict property, and an expect statement each take their property specification and action (IEEE 1800-2023 Sections 16.14 to 16.17)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14 16.14.1 16.15 16.17 A.2.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_statement_forms.expected
*/
// IEEE 1800-2023 §16.14: a concurrent assertion statement is an assert, an
// assume, a cover property, a cover sequence or a restrict property, and a
// concurrent assertion item may have a label (§16.14, A.2.10). The assert and
// assume here carry an action block with a pass and an else statement, and
// their property specification has a clocking event and a disable iff clause
// (§16.15); disable iff stops the evaluation at a tick where it holds. The
// cover property has a statement and another one has the null statement, and
// the cover sequence has its own clocking event and disable iff. The restrict
// property states a property for formal tools; §16.14.3 says it has no effect
// on simulation. The expect statement blocks until its property completes and
// runs the pass or else statement (§16.17).
//
// The signals hold a=1, b=1 at the first tick; a=1, b=0 at the second; 1, 1
// at the third; 0, 0 at the fourth; 1, 0 with dis high at the fifth; and 1, 0
// at the sixth. So assert passes three times and fails twice, assume fails
// twice, the two covers each match once, the assertion whose clock comes from
// its property declaration fails at the third, fifth and sixth tick, and the
// two expect statements, one at the first tick and one at the second, fail and
// pass once each.

`timescale 1ns/1ns

module test_property_statement_forms;
  logic clk = 0, a = 0, b = 0, dis = 0;
  int pass_cnt = 0, fail_cnt = 0, assume_fail = 0;
  int cover_cnt = 0, cover_seq_cnt = 0;
  int p3_pass = 0, p3_fail = 0, exp_pass = 0, exp_fail = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a1: assert property (@(posedge clk) disable iff (dis) 1'b1 |-> (a == b))
    pass_cnt++;
    else fail_cnt++;

  a2: assume property (@(posedge clk) disable iff (dis) 1'b1 |-> (a == b))
    else assume_fail++;

  c1: cover property (@(posedge clk) a ##1 b) cover_cnt++;

  c2: cover sequence (@(posedge clk) disable iff (dis) a ##1 b) cover_seq_cnt++;

  c3: cover property (@(posedge clk) a ##1 b);

  r1: restrict property (@(posedge clk) 1'b1 |-> (a == b));

  property p_clocked;
    @(posedge clk) 1'b1 |-> (a == b);
  endproperty

  a3: assert property (p_clocked) p3_pass++;
    else p3_fail++;

  initial begin
    a = 0;
    b = 0;
    dis = 0;
    #3 a = 1; b = 1;
    #10 a = 1; b = 0;
    #10 a = 1; b = 1;
    #10 a = 0; b = 0;
    #10 dis = 1; a = 1; b = 0;
    #10 dis = 0; a = 1; b = 0;
    #5 $display("assert pass=%0d fail=%0d, assume fail=%0d", pass_cnt, fail_cnt,
                assume_fail);
    $display("cover=%0d, cover sequence=%0d, property clock: pass=%0d fail=%0d",
             cover_cnt, cover_seq_cnt, p3_pass, p3_fail);
    $display("expect: pass=%0d fail=%0d", exp_pass, exp_fail);
    $finish;
  end

  initial begin
    #1;
    expect (@(posedge clk) a ##1 b) exp_pass++;
    else exp_fail++;
  end

  initial begin
    #11;
    expect (@(posedge clk) a ##1 b) exp_pass++;
    else exp_fail++;
  end
endmodule
