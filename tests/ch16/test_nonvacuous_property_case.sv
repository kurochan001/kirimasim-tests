/*
:name: test_nonvacuous_property_case
:description: with the pass actions of vacuous successes turned off, a property case passes nonvacuously exactly when the first item whose expression is case-equal to the case expression, or the default when no item matches, has a nonvacuous attempt, and a case without default where no item matches passes vacuously (IEEE 1800-2023 Section 16.14.8)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.8 20.11 16.12.16 12.5 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_nonvacuous_property_case.expected
*/
// IEEE 1800-2023 §16.14.8, rule af): a property case is nonvacuous exactly
// when, for the first item i whose expression is case-equal (===) to the case
// expression, the attempt of the property of item i is nonvacuous, or when no
// item matches, a default is present and its attempt is nonvacuous.
// §16.12.16: the items are searched in order and the search stops at the
// first match; with no match and no default the case is vacuously true; the
// comparison follows §12.5, so x bits match only x bits. §20.11: after
// $assertvacuousoff only nonvacuous successes run the pass action; failures
// still run the fail action. In a_cd, 1 matches the item 1, 2 first, whose
// g2 |-> x is vacuous at 25, so the later item 1: x does not make it pass;
// 2'bx0 matches the item 2'bx0, whose sequence x is nonvacuous; 3 goes to
// the default go |-> x. a_cn has no default, so it passes vacuously for 2, 3
// and 2'bx0. Every assertion starts at each tick (5 to 95); the action blocks
// (§16.14.1) record the times.

`timescale 1ns/1ns

module test_nonvacuous_property_case;
  logic clk = 0, go = 0, g2 = 0, x = 0;
  logic [1:0] sel = 2'd0;
  int p_cd[$], f_cd[$], p_cn[$], f_cn[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_cd: assert property (@(posedge clk)
    case (sel)
      2'd0: (go |-> x);
      2'd1, 2'd2: (g2 |-> x);
      2'd1: x;
      2'bx0: x;
      default: (go |-> x);
    endcase) p_cd.push_back($time);
    else f_cd.push_back($time);

  a_cn: assert property (@(posedge clk)
    case (sel)
      2'd0: (go |-> x);
      2'd1: x;
    endcase) p_cn.push_back($time);
    else f_cn.push_back($time);

  // Sets the values sampled at the next tick.
  task automatic tick(logic [1:0] vsel, logic vgo, logic vg2, logic vx);
    sel = vsel;
    go = vgo;
    g2 = vg2;
    x = vx;
    #10;
  endtask

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  function automatic void show(string name, int pq[$], int fq[$]);
    $display("%s: passes%s; failures%s", name, times(pq), times(fq));
  endfunction

  initial begin
    $assertvacuousoff;
    //   sel    go g2 x
    tick(2'd0,  1, 0, 1);   // 5
    tick(2'd0,  0, 0, 0);   // 15
    tick(2'd1,  1, 0, 1);   // 25
    tick(2'd1,  0, 1, 0);   // 35
    tick(2'd2,  0, 1, 1);   // 45
    tick(2'd3,  1, 0, 1);   // 55
    tick(2'd3,  0, 0, 1);   // 65
    tick(2'bx0, 0, 0, 1);   // 75
    tick(2'bx0, 0, 0, 0);   // 85
    tick(2'd3,  1, 0, 0);   // 95
    show("case with default", p_cd, f_cd);
    show("case without default", p_cn, f_cn);
    $finish;
  end
endmodule
