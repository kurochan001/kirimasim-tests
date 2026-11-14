/*
:name: test_block_variable_static_and_automatic_lifetimes
:description: a variable without a lifetime qualifier in a static block, task or function keeps its value between entries, while an explicitly automatic variable, the variables of an automatic task, function or block, class method variables and declared for-loop variables are new on each entry and not shared between activations (IEEE 1800-2023 Section 9.3.4)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.4 6.21
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_block_variable_static_and_automatic_lifetimes.expected
*/
// IEEE 1800-2023 §9.3.4 and §6.21: a variable declared without a lifetime
// qualifier in a static block, task or function is static: it has one
// location for the whole simulation, and leaving and entering the block does
// not change it. A variable declared automatic there, a variable of an
// automatic task, function or block, a variable of a class method and a
// variable declared in a for loop are automatic: each entry or call has its
// own copy, initialized on entry.
//
// The test observes each case:
// - kept, declared in an unnamed block of an initial procedure, counts up
//   over three entries of the block, three steps each: 3, 6, 9. fresh,
//   declared automatic in the same block with 10, is 13 after each entry.
// - the static task bump keeps its count over three calls: 1, 2, 3.
// - two concurrent calls of the automatic task work each add their argument
//   to a local that starts at 100, wait 1, and add it again; with one copy
//   each they return 102 and 104. Inside work, the block of the repeat loop
//   is automatic too: its local starts at 7 on both entries.
// - the automatic function sum_down adds n, n-1, ..., 0 through recursion
//   and reads its local here after the recursive call returns; every
//   activation has its own here, so sum_down(4) is 10 (with one shared here
//   the deepest call would leave 0 in it).
// - the class method next starts its local at 1 on each call: 2 and 2.
// - the static task walk loops over a declared variable i and, on each of
//   its two iterations, calls itself one level deep. i is automatic, so the
//   inner call has its own i and the outer loop still makes both iterations:
//   two steps of its own and two of each inner call, 6. With one shared i
//   the first inner loop would end the outer one after 3 steps.
// A tool that made any of these variables static where they are automatic,
// or the reverse, would print another value on that line.
//
// Icarus Verilog 13.0 does not support an automatic variable in a static
// block ("sorry"); the 5.054 release of Verilator prints the expected output.

`timescale 1ns/1ns

module test_block_variable_static_and_automatic_lifetimes;
  int steps, level;
  int r1, r2, inner1, inner2;

  class counter;
    function int next();
      int local_count = 1;
      local_count++;
      return local_count;
    endfunction
  endclass

  task bump(output int result);
    int count;
    count++;
    result = count;
  endtask

  task automatic work(input int id, output int result, output int inner_sum);
    int total = 100;
    inner_sum = 0;
    total += id;
    #1 total += id;
    repeat (2) begin
      int inner = 7;
      inner++;
      inner_sum += inner;
    end
    result = total;
  endtask

  function automatic int sum_down(int n);
    int here = n;
    int rest = 0;
    if (n > 0)
      rest = sum_down(n - 1);
    return here + rest;
  endfunction

  task walk();
    for (int i = 0; i < 2; i++) begin
      steps++;
      if (level == 0) begin
        level = 1;
        walk();
        level = 0;
      end
    end
  endtask

  counter cnt = new;

  initial begin
    repeat (3) begin
      int kept;
      automatic int fresh = 10;
      for (int j = 0; j < 3; j++) begin
        kept++;
        fresh++;
      end
      $display("block entry: kept=%0d fresh=%0d", kept, fresh);
    end
    bump(r1);
    bump(r1);
    bump(r2);
    $display("static task: second call %0d, third call %0d", r1, r2);
    fork
      work(1, r1, inner1);
      work(2, r2, inner2);
    join
    $display("automatic task: %0d %0d, inner block sums %0d %0d", r1, r2, inner1, inner2);
    $display("automatic recursion: %0d", sum_down(4));
    r1 = cnt.next();
    r2 = cnt.next();
    $display("class method: %0d %0d", r1, r2);
    walk();
    $display("for-loop variable: %0d steps", steps);
  end
endmodule
