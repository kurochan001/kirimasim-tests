/*
:name: test_sampled_function_arguments
:description: $rose, $fell, $stable and $changed take an optional clocking event and $past an optional number of ticks, gating expression and clocking event, with a comma for each argument left out before a given one; a clock given in the call can differ from the clock of the procedure, and $sampled gives the sampled value also in an action block and a disable condition (IEEE 1800-2023 Section 16.9.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.3 16.5.1 16.12 16.14.6 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sampled_function_arguments.expected
*/
// IEEE 1800-2023 §16.9.3: $rose, $fell, $stable and $changed compare the
// sampled value (§16.5.1) with the one at the previous tick of their clock,
// or with the default sampled value before the first; the clock can be given
// as a second argument. $past(e, n, g, ev) is the sampled value of e at the
// n-th strictly prior tick of ev iff g (n defaults to 1, g to 1, ev to the
// inferred clock), or the default sampled value if there are fewer such
// ticks; a comma stands for each argument left out before a given one. A clock
// given in the call may differ from the clock of the context, and then the
// history follows it. The always procedure is clocked by posedge clk
// (§16.14.6), rising at 5, 15, ..., 55; clk2 rises at 8, 18, ..., 48. e
// changes between the ticks and is sampled as 1, 3, 4, 4, 6, 8 at the ticks
// of clk and as 2, 5, 9, 6, 9 at those of clk2; g is high at the ticks at 5,
// 25 and 35 of clk and at 8, 28 and 38 of clk2. Each first line shows the
// value change functions for clk and then for clk2; each second line the
// $past forms in the order of the call. §16.12: a disable condition uses
// current values unless $sampled is used: rst rises at 25, in the time step
// of a tick, so a_dis_cur is disabled there while a_dis_smp fails; its
// action prints $sampled(rst) and rst (§16.14.1).

`timescale 1ns/1ns

module test_sampled_function_arguments;
  logic clk = 0, clk2 = 0, g = 1, rst = 0;
  logic [3:0] e = 4'd0;
  int f_cur[$];

  always #5 clk = ~clk;

  function automatic string times(int t[$]);
    string str = "";
    foreach (t[i]) str = {str, $sformatf(" %0d", t[i])};
    return str;
  endfunction

  initial begin
    #8;
    forever begin
      clk2 = 1;
      #5 clk2 = 0;
      #5;
    end
  end

  always @(posedge clk) begin
    $display("t=%0t e=%0d: rose %b/%b, fell %b/%b, stable %b/%b, changed %b/%b", $time,
             $sampled(e), $rose(e), $rose(e, @(posedge clk2)), $fell(e), $fell(e, @(posedge clk2)),
             $stable(e), $stable(e, @(posedge clk2)), $changed(e), $changed(e, @(posedge clk2)));
    $display("t=%0t past: %0d %0d %0d %0d %0d %0d %0d", $time, $past(e), $past(e, 2),
             $past(e, 2, g), $past(e, 1, g, @(posedge clk2)), $past(e, , g),
             $past(e, , , @(posedge clk2)), $past(e, 2, , @(posedge clk2)));
  end

  a_dis_cur: assert property (@(posedge clk) disable iff (rst) 1'b0) else f_cur.push_back($time);
  a_dis_smp: assert property (@(posedge clk) disable iff ($sampled(rst)) 1'b0)
    else $display("t=%0t a_dis_smp fail: $sampled(rst)=%b rst=%b", $time, $sampled(rst), rst);

  initial begin
    #2 e = 1;
    #5 e = 2;      // 7
    #3 g = 0;      // 10
    #2 e = 3;      // 12
    #5 e = 5;      // 17
    #3 g = 1;      // 20
    #2 e = 4;      // 22
    #3 rst = 1;    // 25
    #2 e = 9;      // 27
    #3 rst = 0;    // 30
    #2 e = 4;      // 32
    #5 e = 6;      // 37
    #3 g = 0;      // 40
    #7 e = 9;      // 47
    #5 e = 8;      // 52
    #6;            // 58
    $display("a_dis_cur failures:%s", times(f_cur));
    $finish;
  end
endmodule
