/*
:name: test_sva_property_grammar_forms
:description: A named property takes formals, assertion local declarations, a property_spec with a clocking event and a disable condition and a closing label, and Syntax 16-16 admits sequence strength, Boolean, implication, temporal, abort, case and instance forms; the asserted instance and the covers report their times (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12 16.12.2 16.12.6 16.12.12 16.13.5 16.12.21 A.2.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sva_property_grammar_forms.expected
*/
// IEEE 1800-2023 Section 16.12, Syntax 16-16: a named property is written
// between property and endproperty, may take formal arguments, may declare
// assertion local variables, has a property_spec (here a clocking event and a
// disable condition) and may close with its name. The same syntax admits the
// sequence strength (weak and strong), a Boolean expression, the implication
// forms, the temporal forms (##, [*], [->], throughout, within, intersect and
// first_match), the abort forms, case and if-else, and an instance of a named
// sequence. Every form is written in this design, so a tool that cannot read
// one of them cannot run the test.
//
// p_chk has the formals en and lim, the local cnt, the clocking event
// posedge clk, disable iff rst and the closing label. rst stays 0, so each of
// its attempts at the ticks 5, 15 and 25 passes in the same tick, where cnt
// has just been assigned lim. The sequence sq_formal takes two typed formals
// and closes with its name; it succeeds at the tick after a tick where both
// are high, here at 25. p_bool is a && !b, high only at 15. The queues are
// printed in a fixed order, so the order within one time step does not matter.

`timescale 1ns/1ns

module test_sva_property_grammar_forms;
  logic clk = 0, a = 0, b = 0, rst = 0;
  int tf[$], ti[$], tb[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25

  default clocking dc @(posedge clk);
  endclocking

  sequence sq_formal(bit x, bit y);
    x ##1 y;
  endsequence : sq_formal

  property p_chk(bit en, int lim);
    int cnt;
    @(posedge clk) disable iff (rst) (en, cnt = lim) |-> (cnt == lim);
  endproperty : p_chk

  property p_bool;
    a && !b;
  endproperty

  property p_impl;
    a |-> b;
  endproperty

  property p_impl_next;
    a |=> b;
  endproperty

  property p_temporal;
    first_match(a ##[1:2] b) and (b[->1] ##1 a[*1:2])
    and (a throughout b) and ((a ##1 b) within (a ##1 b ##1 a))
    and ((a ##1 b) intersect (a ##1 b));
  endproperty

  property p_abort;
    accept_on(rst) (a ##1 b);
  endproperty

  property p_case;
    case (a) 1: b; default: a; endcase
  endproperty

  property p_if;
    if (a) b else a;
  endproperty

  property p_strength;
    weak(a ##1 b);
  endproperty

  property p_strong;
    strong(a ##1 b);
  endproperty

  property p_instance;
    sq_formal(a, b);
  endproperty

  ap_chk: assert property (p_chk(1, 3)) tf.push_back(int'($time));
  ap_seq: cover property (sq_formal(a, b)) ti.push_back(int'($time));
  ap_bool: cover property (p_bool) tb.push_back(int'($time));

  initial begin
    @(negedge clk) a = 1;   // sampled at 5 and 15
    @(negedge clk) b = 1;   // sampled at 15
    @(negedge clk) a = 0;   // sampled at 25
    #1;
    $write("formal:"); foreach (tf[i]) $write(" %0d", tf[i]); $write("\n");
    $write("instance:"); foreach (ti[i]) $write(" %0d", ti[i]); $write("\n");
    $write("boolean:"); foreach (tb[i]) $write(" %0d", tb[i]); $write("\n");
    $finish;
  end
endmodule
