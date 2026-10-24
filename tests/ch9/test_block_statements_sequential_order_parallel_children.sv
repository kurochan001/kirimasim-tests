/*
:name: test_block_statements_sequential_order_parallel_children
:description: a begin-end block runs its statements one after another in order and acts as one statement under if and repeat, and a fork block with join, join_any or join_none starts its statements together (IEEE 1800-2023 Section 9.3)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3 9.3.1 9.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_block_statements_sequential_order_parallel_children.expected
*/
// IEEE 1800-2023 §9.3: a block groups statements so that they act as one
// statement. A sequential block, delimited by begin and end, runs its
// statements in the order given; a parallel block, delimited by fork and
// join, join_any or join_none, runs its statements concurrently.
//
// Order: three assignments in a begin-end block read the results of the
// earlier ones, so another order gives other values; two delays in a
// begin-end block add up (2, then 5). Grouping: a begin-end block is the
// whole body of repeat and of an if whose condition is false, and the same
// two statements written without the block leave the second one outside the
// if. Concurrency: in fork-join the delays 2 and 3 both count from the start
// of the block (7 and 8, not 7 and 10); join_any goes on after the first
// child ends while the other child runs on; join_none goes on at once.

`timescale 1ns/1ns

module test_block_statements_sequential_order_parallel_children;
  int a, b, n, c;

  initial begin
    begin
      a = 1;
      b = a + 1;
      a = b * 3;
    end
    $display("order: a=%0d b=%0d", a, b);

    n = 0;
    c = 0;
    repeat (3) begin
      n = n + 1;
      c = c + 10;
    end
    if (n == 0) begin
      n = 100;
      c = 100;
    end
    $display("grouped: n=%0d c=%0d", n, c);
    if (n == 0) n = 200;
    c = 7;
    $display("ungrouped: n=%0d c=%0d", n, c);

    begin
      #2 $display("%0t seq first", $time);
      #3 $display("%0t seq second", $time);
    end

    fork
      #2 $display("%0t join child 2", $time);
      #3 $display("%0t join child 3", $time);
    join
    $display("%0t after join", $time);

    fork
      #4 $display("%0t join_any child 4", $time);
      #1 $display("%0t join_any child 1", $time);
    join_any
    $display("%0t after join_any", $time);

    fork
      #1 $display("%0t join_none child 1", $time);
    join_none
    $display("%0t after join_none", $time);
    #5 $display("%0t done", $time);
  end
endmodule
