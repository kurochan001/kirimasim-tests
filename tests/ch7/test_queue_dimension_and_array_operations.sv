/*
:name: test_queue_dimension_and_array_operations
:description: a queue dimension is [$] or [$:N] with N the highest index allowed, and queues support indexing with $, concatenation, slicing, equality and the other operations of fixed-size unpacked arrays: element writes, whole assignment to and from fixed arrays, foreach, array methods and array queries (IEEE 1800-2023 Sections 7.10, 7.10.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.1 20.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_dimension_and_array_operations.expected
*/
// IEEE 1800-2023 §7.10: a queue is declared with the dimension [$], or with
// [$:N], where the constant N is the largest index the queue may have, so it
// holds at most N+1 elements. Queues can be manipulated with indexing (0 is
// the first element, $ the last), concatenation, slicing and the equality
// operators. §7.10.1: queues support the operations of fixed-size unpacked
// arrays, and also resize themselves to the values written to them.
// uq ([$]) takes 300 pushes; bq ([$:9]) keeps 10 of them. q is compared with
// == and != before and after a change, read with $ and with a slice, extended
// by concatenation, written element by element and as a whole from a fixed
// array, which it is also assigned to; foreach, sum, sort and $size and
// $right (§20.7) work on it as on the fixed array.
// Icarus Verilog 13.0 does not support equality of queues. The release
// 5.052 of Verilator rejects the assignment of the slice q[0:2] to the fixed
// array g, and its C++ code for q = f does not compile.

module test_queue_dimension_and_array_operations;
  int uq[$];
  int bq[$:9];
  int q[$] = '{3, 1, 2};
  int r[$] = '{3, 1, 2};
  int f [0:3] = '{40, 30, 20, 10};
  int g [1:3];
  int total;

  initial begin
    repeat (300) begin
      uq.push_back(1);
      bq.push_back(1);
    end
    $display("dimensions: [$] size=%0d [$:9] size=%0d", uq.size(), bq.size());
    $display("equality: q==r=%0d q!=r=%0d", q == r, q != r);
    r[1] = 9;
    $display("after r[1]=9: q==r=%0d q!=r=%0d", q == r, q != r);
    $display("indexing: q[0]=%0d q[$]=%0d q[$-1]=%0d", q[0], q[$], q[$-1]);
    q = {q, 4};
    q = {0, q[1:$]};
    $display("concatenation and slice: size=%0d %0d %0d %0d %0d", q.size(), q[0], q[1], q[2],
             q[3]);
    q[2] = 7;
    total = 0;
    foreach (q[i]) total += i * q[i];
    $display("element write and foreach: q[2]=%0d weighted sum=%0d", q[2], total);
    $display("methods: sum=%0d $size=%0d $right=%0d", q.sum(), $size(q), $right(q));
    q = f;
    q.sort();
    g = q[0:2];
    $display("with fixed arrays: q size=%0d first=%0d g[1]=%0d g[3]=%0d", q.size(), q[0], g[1],
             g[3]);
  end
endmodule
