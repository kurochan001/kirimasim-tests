/*
:name: test_followed_by_dual_forms
:description: s #-# p fails exactly where not (s |-> not p) does and s #=# p where not (s |=> not p) does, an empty match of s starts the consequent of #=# at the current tick, and s #-# strong(r) and s #=# strong(r) agree with strong(s ##0 r) and strong(s ##1 r) (IEEE 1800-2023 Section 16.12.9)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.9 16.12.7 16.12.3 16.12.2 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_followed_by_dual_forms.expected
*/
// IEEE 1800-2023 §16.12.9: s #-# p holds if some match of s is followed by p
// from its end tick, and s #=# p if p holds from the tick after some
// nonempty match, or from the current tick after an empty match; they are
// the duals not (s |-> not p) and not (s |=> not p) of the implications
// (§16.12.7, §16.12.3). So s #-# strong(r) is strong(s ##0 r) and s #=#
// strong(r) is strong(s ##1 r) (§16.12.2). Each form is asserted next to its
// dual under go |->, and the fail actions (§16.14.1) count the failures of
// each phase. go is high at the first tick T of a phase; p, q and r at T to
// T+3 are the bits of the arguments, the leftmost for T. The forms are
// A: ##[1:2] p #-# q, which needs p and q at T+1 or at T+2; B: ##[1:2] p
// #=# q, p at T+k and q at T+k+1; C: p[*0:1] #=# q, q at T (the empty match)
// or p at T and q at T+1; D: p #-# strong(r ##1 q), p and r at T and q at
// T+1; E: p #=# strong(r ##1 q), p at T, r at T+1 and q at T+2.

`timescale 1ns/1ns

module test_followed_by_dual_forms;
  logic clk = 0, go = 0, p = 0, q = 0, r = 0;
  int f[string];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  function automatic void fail(string name);
    f[name]++;
  endfunction

  a_a: assert property (@(posedge clk) go |-> (##[1:2] p #-# q)) else fail("A");
  a_a2: assert property (@(posedge clk) go |-> not (##[1:2] p |-> not q)) else fail("A dual");
  a_b: assert property (@(posedge clk) go |-> (##[1:2] p #=# q)) else fail("B");
  a_b2: assert property (@(posedge clk) go |-> not (##[1:2] p |=> not q)) else fail("B dual");
  a_c: assert property (@(posedge clk) go |-> (p[*0:1] #=# q)) else fail("C");
  a_c2: assert property (@(posedge clk) go |-> not (p[*0:1] |=> not q)) else fail("C dual");
  a_d: assert property (@(posedge clk) go |-> (p #-# strong(r ##1 q))) else fail("D");
  a_d2: assert property (@(posedge clk) go |-> strong(p ##0 r ##1 q)) else fail("D dual");
  a_e: assert property (@(posedge clk) go |-> (p #=# strong(r ##1 q))) else fail("E");
  a_e2: assert property (@(posedge clk) go |-> strong(p ##1 r ##1 q)) else fail("E dual");

  function automatic int n(string name);
    return f.exists(name) ? f[name] : 0;
  endfunction

  // Runs one phase of five ticks; go is high at the first.
  task automatic phase(logic [0:3] ps, logic [0:3] qs, logic [0:3] rs);
    for (int i = 0; i < 5; i++) begin
      go = (i == 0);
      p = i < 4 ? ps[i] : 1'b0;
      q = i < 4 ? qs[i] : 1'b0;
      r = i < 4 ? rs[i] : 1'b0;
      #10;
    end
    $display("p %b q %b r %b: A %0d/%0d, B %0d/%0d, C %0d/%0d, D %0d/%0d, E %0d/%0d", ps, qs, rs,
             n("A"), n("A dual"), n("B"), n("B dual"), n("C"), n("C dual"), n("D"), n("D dual"),
             n("E"), n("E dual"));
    f.delete();
  endtask

  initial begin
    phase(4'b0110, 4'b0010, 4'b0000);
    phase(4'b1100, 4'b1010, 4'b1100);
    phase(4'b1000, 4'b0100, 4'b1000);
    phase(4'b0000, 4'b1111, 4'b0000);
    $finish;
  end
endmodule
