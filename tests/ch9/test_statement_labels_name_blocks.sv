/*
:name: test_statement_labels_name_blocks
:description: a label before begin or fork names the block like a block name after the keyword, a label on a for loop with a declared variable or on a foreach loop names the loop's implicit block, and a label on another statement wraps it in a named block; each can be referenced and disabled by that name (IEEE 1800-2023 Section 9.3.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.5 9.3.4 9.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_statement_labels_name_blocks.expected
*/
// IEEE 1800-2023 §9.3.5: a statement label before begin or fork is the same
// as a block name after the keyword, and the matching name may follow end
// or join. A label on a foreach loop, or on a for loop that declares its
// variable, names the implicit block of the loop; on other statements a
// label creates a named begin-end block around the statement. A labeled
// statement can be disabled like a named block (9.6.2).
//
// lb: begin ... end : lb declares v; another process reads lb.v by the
// label. lf: fork ... join_none : lf and the loops lp (for), fe (foreach)
// and the statement ws (a wait) are disabled at time 5 by their labels:
//   lp counts at 2 and 4 and ends; the static cnt of its body is reached
//      as lp.body.cnt
//   fe counts at 2 and 4 and ends
//   ws stops waiting; its assignment never runs
//   lf's branch that would set a at 20 ends; a keeps 1 (set at 1)
// Each process records the time at which it went on and the values, and
// they are printed at time 30.
//
// Icarus Verilog 13.0 does not accept a label before begin. The 5.052
// release of Verilator does not find lp.body, the named body block inside
// the implicit block that the label lp names; it handles the rest.

`timescale 1ns/1ns
module test_statement_labels_name_blocks;
  int n = 0, m = 0, y = 0, a = 0;
  int arr [0:9];
  bit go = 0;
  int t_lp = -1, t_fe = -1, t_ws = -1, lbv = -1, cnt_seen = -1;

  initial begin
    lb: begin
      int v;
      v = 4;
      #10 v = 5;
    end : lb
  end

  initial begin
    lp: for (int i = 0; i < 10; i++) begin : body
      int cnt;
      #2 n++;
      cnt = n;
    end
    t_lp = $time;
  end

  initial begin
    fe: foreach (arr[k]) begin
      #2 m++;
    end
    t_fe = $time;
  end

  initial begin
    ws: wait (go) y = 1;
    t_ws = $time;
  end

  initial begin
    lf: fork
      #1 a = 1;
      #20 a = 2;
    join_none : lf
  end

  initial begin
    #5;
    lbv = lb.v;
    cnt_seen = lp.body.cnt;
    disable lp;
    disable fe;
    disable ws;
    disable lf;
    #25;
    $display("lb.v at 5: %0d", lbv);
    $display("lp: over at t=%0d, n=%0d, lp.body.cnt at 5: %0d", t_lp, n, cnt_seen);
    $display("fe: over at t=%0d, m=%0d", t_fe, m);
    $display("ws: over at t=%0d, y=%0d", t_ws, y);
    $display("lf: a=%0d", a);
  end
endmodule
