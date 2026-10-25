/*
:name: test_cover_pass_statements
:description: the pass statement of cover property runs once per successful attempt and that of cover sequence once per match that completes before the disable condition, in the Reactive region of the tick of the success or match; the matches are those for which the equivalent assertion with a match item calls its function; the action control tasks suppress the pass statements (IEEE 1800-2023 Section 16.14.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.3 16.11 20.11 16.12 4.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cover_pass_statements.expected
*/
// IEEE 1800-2023 §16.14.3: the pass statement of a cover property runs once
// for each successful evaluation attempt, and that of a cover sequence once
// for each match of the attempt that completes without the disable iff
// condition, with multiplicity; both run in the Reactive region of the time
// step of the success or match, and the action control tasks (§20.11)
// control them. The matches counted for a cover sequence attempt are the
// calls of the function in the attempt of assert property (... seq |->
// (1'b1, f())), whose match item (§16.11) calls f at each end point of seq,
// in the Reactive region too. Here seq is a ##[1:3] b with disable iff (rst),
// and n is increased by a nonblocking assignment at each tick (§4.4.2), so it
// is k at the k-th tick before the Reactive region; the statements and f
// record n. a is high at the ticks 1, 6, 11 and 14, b at 2 to 4, 7 to 9, 12
// and 15, and rst from just before tick 8 to just after it (§16.12: the
// attempt from 6 is disabled there, after its match at 7). The pass actions
// are off around tick 12, where f, which is not an action, still runs.
// Icarus Verilog 13.0 does not support these assertions. The 5.052 release
// of Verilator runs the pass statements before the NBA region, so they
// record k - 1, and never calls f.

`timescale 1ns/1ns

module test_cover_pass_statements;
  logic clk = 0, a = 0, b = 0, rst = 0;
  int n = 0;
  int q_prop[$], q_seq[$], q_eq[$];

  always #5 clk = ~clk;   // tick k at 10 * k - 5

  always @(posedge clk) n <= n + 1;

  function automatic void f();
    q_eq.push_back(n);
  endfunction

  c_prop: cover property (@(posedge clk) disable iff (rst) a ##[1:3] b) q_prop.push_back(n);
  c_seq: cover sequence (@(posedge clk) disable iff (rst) a ##[1:3] b) q_seq.push_back(n);
  a_eq: assert property (@(posedge clk) disable iff (rst) (a ##[1:3] b) |-> (1'b1, f()));

  function automatic string ticks(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  // Sets the values sampled at the next tick.
  task automatic tick(logic va, logic vb);
    a = va;
    b = vb;
    #10;
  endtask

  initial begin
    tick(1, 0); tick(0, 1); tick(0, 1); tick(0, 1); tick(0, 0);   // ticks 1 to 5
    tick(1, 0); tick(0, 1);                                       // ticks 6, 7
    rst = 1; a = 0; b = 1;                                        // tick 8, rst from 70
    #8 rst = 0;
    #2 tick(0, 1); tick(0, 0);                                    // ticks 9, 10
    $assertpassoff;
    tick(1, 0); tick(0, 1); tick(0, 0);                           // ticks 11 to 13
    $assertpasson;
    tick(1, 0); tick(0, 1); tick(0, 0); tick(0, 0); tick(0, 0);   // ticks 14 to 18
    $display("cover property pass statement at ticks%s", ticks(q_prop));
    $display("cover sequence pass statement at ticks%s", ticks(q_seq));
    $display("match item of the equivalent assertion at ticks%s", ticks(q_eq));
    $finish;
  end
endmodule
