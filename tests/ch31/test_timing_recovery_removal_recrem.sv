/*
:name: test_timing_recovery_removal_recrem
:description: $recovery reports a clock edge from the release of a control signal up to, not including, the limit after it, $removal a clock edge strictly inside the limit before the release, and $recrem both, including simultaneous edges (IEEE 1800-2023 Sections 31.3.4, 31.3.5, 31.3.6)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.4 31.3.5 31.3.6 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_recovery_removal_recrem.expected
*/
// IEEE 1800-2023 §31.3.5: $recovery(posedge clr, posedge clk, 4, n) takes the
// clr edge as timestamp and reports a clk edge at it or less than 4 after it.
// §31.3.4: $removal(posedge clr, posedge clk, 3, n) takes the clr edge as
// timecheck and reports a clk edge strictly between 3 before it and it.
// §31.3.6: $recrem(posedge clr, posedge clk, 4, 3, n) uses the removal limit
// when clk comes first and the recovery limit when clr comes first, and
// reports simultaneous edges. §31.6: each violation toggles the notifier. The
// test records when each notifier changes. The clr edges are at 10, 30, 50, 70
// and 90; the clk edges at 12, 34 (exactly 4 after), 48, 67 (exactly 3
// before) and 90.

`timescale 1ns/1ns

module timing_rec_rem(input clr, input clk);
  reg n_rec = 0, n_rem = 0, n_recrem = 0;
  specify
    $recovery(posedge clr, posedge clk, 4, n_rec);
    $removal(posedge clr, posedge clk, 3, n_rem);
    $recrem(posedge clr, posedge clk, 4, 3, n_recrem);
  endspecify
endmodule

module test_timing_recovery_removal_recrem;
  reg clr = 0, clk = 0;
  int t_rec[$], t_rem[$], t_recrem[$];

  timing_rec_rem u(clr, clk);

  always @(u.n_rec) t_rec.push_back($time);
  always @(u.n_rem) t_rem.push_back($time);
  always @(u.n_recrem) t_recrem.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #10 clr = 1;              // 10
    #2 clk = 1;               // 12: 2 after clr
    #3 clr = 0; clk = 0;
    #15 clr = 1;              // 30
    #4 clk = 1;               // 34: exactly 4 after clr
    #3 clr = 0; clk = 0;
    #11 clk = 1;              // 48
    #2 clr = 1;               // 50: clk 2 before
    #3 clr = 0; clk = 0;
    #14 clk = 1;              // 67
    #3 clr = 1;               // 70: clk exactly 3 before
    #3 clr = 0; clk = 0;
    #17 clr = 1; clk = 1;     // 90: together
    #3 clr = 0; clk = 0;
    #10;
    $display("$recovery:%s", times(t_rec));
    $display("$removal:%s", times(t_rem));
    $display("$recrem:%s", times(t_recrem));
    $finish;
  end
endmodule
