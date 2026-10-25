/*
:name: test_array_query_increment_right_bounds
:description: $increment is 1 for a fixed dimension whose left bound is not below its right bound and -1 otherwise and for dynamic arrays and queues, and $right is the right bound, the least significant packed index, or -1 for an empty dynamic array or queue (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_query_increment_right_bounds.expected
*/
// IEEE 1800-2023 §20.7: for a fixed-size dimension $increment is 1 when
// $left >= $right and -1 when $left < $right; for a dynamic array or queue
// dimension it is -1. $right is the right bound of the dimension, which for
// a packed dimension is the index of its least significant element; for a
// dynamic array or queue it is $size - 1, and -1 when the array is empty,
// while $left is 0.
// The fixed cases are packed [7:0], [0:7] and [3:3], unpacked [2:5] and
// [5:2], and both dimensions of a packed [1:4][7:6]. A dynamic array and a
// queue are queried empty and after getting 3 and 4 elements.
// Icarus Verilog 13.0 gives $increment 2 for the dynamic array of 3 elements
// and 0 for the queue, and $right 0 for the queue.

module test_array_query_increment_right_bounds;
  logic [7:0] dn;
  logic [0:7] up;
  logic [3:3] eq;
  int ua [2:5];
  int ub [5:2];
  bit [1:4][7:6] pm;
  int dyn [];
  byte q [$];

  initial begin
    $display("dn %0d %0d up %0d %0d eq %0d %0d", $increment(dn), $right(dn), $increment(up),
             $right(up), $increment(eq), $right(eq));
    $display("ua %0d %0d ub %0d %0d pm1 %0d %0d pm2 %0d %0d", $increment(ua), $right(ua),
             $increment(ub), $right(ub), $increment(pm, 1), $right(pm, 1), $increment(pm, 2),
             $right(pm, 2));
    $display("dyn empty %0d %0d %0d %0d", $increment(dyn), $left(dyn), $right(dyn), $size(dyn));
    $display("q empty %0d %0d %0d %0d", $increment(q), $left(q), $right(q), $size(q));
    dyn = new[3];
    repeat (4) q.push_back(8'd0);
    $display("dyn 3 %0d %0d %0d %0d", $increment(dyn), $left(dyn), $right(dyn), $size(dyn));
    $display("q 4 %0d %0d %0d %0d", $increment(q), $left(q), $right(q), $size(q));
  end
endmodule
