/*
:name: test_nonoverlapped_implication_expansion
:description: seq |=> p fails and passes exactly where seq ##1 1 |-> p does; a nonempty match of seq starts p at the next tick, and an empty match starts it at the tick where seq began (IEEE 1800-2023 Section 16.12.7)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.7 16.9.2.1 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonoverlapped_implication_expansion.expected
*/
// IEEE 1800-2023 §16.12.7: for seq |=> p, a nonempty match of seq starts the
// evaluation of p at the tick after its end, and an empty match starts it at
// the tick where the evaluation of seq began, for a single clock; so seq |=>
// p is the same as seq ##1 1 |-> p, where (empty ##1 1) is (##0 1)
// (§16.9.2.1). The assertions check b after a[*0:1], which matches empty at
// every tick and also over one tick where a holds, after a[*0], which only
// matches empty, and after a ##1 c, which has no empty match; each form is
// next to its expansion. a, b and c at ticks 0 to 7 (5 to 75) are the bits
// of va, vb and vc. With a[*0:1] the attempt at a tick needs b at that
// tick and, when a holds, at the next one: it fails at 25 for the attempts
// from 15 and 25, and at 55. a[*0] needs b at every tick: failures at 25
// and 55. a ##1 c holds from 35 to 45, and b is low at 55: a failure at 55.
// The fail actions (§16.14.1) record the times; every attempt ends by 75.
// [*0] is not supported by Verilator 5.052.

`timescale 1ns/1ns

module test_nonoverlapped_implication_expansion;
  logic clk = 0, a = 0, b = 0, c = 0;
  int f_e[$], f_ex[$], f_z[$], f_zx[$], f_n[$], f_nx[$];
  // Bit n of each vector is the value at tick n (at 10 * n + 5).
  logic [7:0] va = 8'b0000_1010, vb = 8'b1101_1011, vc = 8'b0001_0000;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_e: assert property (@(posedge clk) a[*0:1] |=> b) else f_e.push_back($time);
  a_ex: assert property (@(posedge clk) a[*0:1] ##1 1'b1 |-> b) else f_ex.push_back($time);
  a_z: assert property (@(posedge clk) a[*0] |=> b) else f_z.push_back($time);
  a_zx: assert property (@(posedge clk) a[*0] ##1 1'b1 |-> b) else f_zx.push_back($time);
  a_n: assert property (@(posedge clk) a ##1 c |=> b) else f_n.push_back($time);
  a_nx: assert property (@(posedge clk) a ##1 c ##1 1'b1 |-> b) else f_nx.push_back($time);

  function automatic string times(int t[$]);
    string str = "";
    foreach (t[i]) str = {str, $sformatf(" %0d", t[i])};
    return str;
  endfunction

  initial begin
    for (int n = 0; n < 8; n++) begin
      a = va[n];
      b = vb[n];
      c = vc[n];
      #10;
    end
    $display("a[*0:1] |=> b: failures%s", times(f_e));
    $display("a[*0:1] ##1 1 |-> b: failures%s", times(f_ex));
    $display("a[*0] |=> b: failures%s", times(f_z));
    $display("a[*0] ##1 1 |-> b: failures%s", times(f_zx));
    $display("a ##1 c |=> b: failures%s", times(f_n));
    $display("a ##1 c ##1 1 |-> b: failures%s", times(f_nx));
    $finish;
  end
endmodule
