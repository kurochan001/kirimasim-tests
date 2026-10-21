/*
:name: test_followed_by_existential
:description: a followed-by property holds if the consequent holds after at least one match of the antecedent, where an implication needs it after every match; cover property counts such a property once per attempt; implies and iff take vacuously true implications as true (IEEE 1800-2023 Sections 16.12.9, 16.12.8)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.9 16.12.8 16.12.7 16.14.3 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_followed_by_existential.expected
*/
// IEEE 1800-2023 §16.12.9: s #-# r is true if some match of s is followed by r
// from its end tick, and s #=# r if r holds from the tick after some match;
// they are the duals of s |-> r and s |=> r (§16.12.7), which need r after
// every match. Here s is ##[1:2] p, which can match at T+1 and T+2, and r is q.
// A cover property succeeds at most once per attempt (§16.14.3), so the
// followed-by cover counts one success for a start with two matches followed by
// q. §16.12.8: p1 implies p2 is true if p1 is false or p2 true, p1 iff p2 if
// both are true or both false; an implication is true at a tick without go, so
// there a_iff holds and a_implies fails, its left side being true and its right
// side, a negation, false. go is high at the first tick T of each phase; p and
// q are as listed at T+1 and T+2 (q also at T+3). The fail actions (§16.14.1)
// and the cover count per phase. The first four assertions are guarded by go;
// a_iff and a_implies are not, and a phase has five ticks.

`timescale 1ns/1ns

module test_followed_by_existential;
  logic clk = 0, go = 0, p = 0, q = 0;
  int f_ov = 0, f_ov_imp = 0, f_nov = 0, f_nov_imp = 0, n_cover = 0, f_iff = 0, f_implies = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_ov: assert property (@(posedge clk) go |-> (##[1:2] p #-# q)) else f_ov++;
  a_ov_imp: assert property (@(posedge clk) go |-> (##[1:2] p |-> q)) else f_ov_imp++;
  a_nov: assert property (@(posedge clk) go |-> (##[1:2] p #=# q)) else f_nov++;
  a_nov_imp: assert property (@(posedge clk) go |-> (##[1:2] p |=> q)) else f_nov_imp++;
  c_ov: cover property (@(posedge clk) go ##[1:2] p #-# q) n_cover++;
  a_iff: assert property (@(posedge clk) (go |-> ##1 p) iff (go |-> ##1 q)) else f_iff++;
  a_implies: assert property (@(posedge clk) (go |-> ##1 p) implies not (go |-> ##1 q))
    else f_implies++;

  // Runs one phase: go at T, p at T+1 and T+2, q at T+1 to T+3.
  task automatic phase(logic [1:2] ps, logic [1:3] qs);
    go = 1; p = 0; q = 0; #10;
    go = 0;
    for (int i = 1; i <= 3; i++) begin
      p = i <= 2 ? ps[i] : 1'b0;
      q = qs[i];
      #10;
    end
    p = 0; q = 0; #10;
    $display("p %b, q %b: #-# %0d, |-> %0d, #=# %0d, |=> %0d, cover %0d, iff %0d, implies %0d",
             ps, qs, f_ov, f_ov_imp, f_nov, f_nov_imp, n_cover, f_iff, f_implies);
    f_ov = 0;
    f_ov_imp = 0;
    f_nov = 0;
    f_nov_imp = 0;
    n_cover = 0;
    f_iff = 0;
    f_implies = 0;
  endtask

  initial begin
    phase(2'b11, 3'b010);
    phase(2'b11, 3'b111);
    phase(2'b01, 3'b001);
    $finish;
  end
endmodule
