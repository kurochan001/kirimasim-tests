/*
:name: test_foreach_label_scope_automatic
:description: A foreach loop wraps itself in an implicit block holding its loop variables with automatic lifetime, which a statement label names, so its variables are local to the loop and separate for each call of a static task (IEEE 1800-2023 Section 12.7.3)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.3 9.3.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_foreach_label_scope_automatic.expected
*/
// IEEE 1800-2023 §12.7.3: like a for loop, a foreach loop creates an
// implicit begin-end block around itself that declares its loop variables
// with automatic lifetime in a new scope; the block is unnamed unless a
// statement label names it (9.3.5).
//
// The module has a variable k = 100; a foreach loop with the loop variable
// k leaves it unchanged. %m in the body of a labelled foreach ends in the
// label. The static task run3 waits 2 in each iteration of a foreach over
// three elements; it is called by two processes that overlap in time (from
// 10 and from 11). The loop variable is automatic, so each call has its
// own j and both print j = 0, 1, 2; a static j shared by both calls would
// be advanced by the other call.
//
// Simulator notes: Icarus Verilog 13.0 rejects the statement label before a
// foreach loop, and without that line it shares j between the two calls of
// run3 (t=13 j=1, t=14 j=2, t=15 j=3). In a run with Verilator 5.052 %m in
// the labelled loop ends in lbl.unnamedblk3: the label makes a block of its
// own around the implicit block instead of naming it.

`timescale 1ns/1ns

module test_foreach_label_scope_automatic;
  int arr [3];
  int k = 100;

  task run3(); // static task: its ordinary locals would be shared
    foreach (arr[j]) begin
      #2 $display("t=%0t j=%0d", $time, j);
    end
  endtask

  initial begin : blk
    foreach (arr[k]) arr[k] = k;
    $display("after foreach (arr[k]): module k=%0d, arr = %0d %0d %0d", k, arr[0], arr[1], arr[2]);
    lbl: foreach (arr[m]) if (m == 0) $display("body of lbl: foreach: %m");
  end

  initial begin
    #10;
    fork
      run3();
      #1 run3();
    join
    $display("t=%0t done", $time);
  end
endmodule
