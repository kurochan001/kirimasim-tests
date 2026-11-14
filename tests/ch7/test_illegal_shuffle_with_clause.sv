/*
:name: test_illegal_shuffle_with_clause
:description: a with clause on the array ordering method shuffle() is a compilation error, while the same with clause on rsort() is legal (IEEE 1800-2023 Section 7.12.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call of shuffle() on the queue q has a with clause
:expected_stderr_regex: test_illegal_shuffle_with_clause\.sv:36:
*/
// IEEE 1800-2023 §7.12.2: shuffle() puts the elements of an array in a random
// order, and giving it a with clause shall be a compiler error. rsort() may
// take a with clause whose expression gives the sort key.
// The legal design sorts q with rsort() and the clause with (-item), which
// puts the elements in ascending order of their values, and prints them:
// 1 2 3. It then calls shuffle() without a with clause; the order it leaves
// is random, so the design sorts q again and prints its size and elements:
// 3 1 2 3. The last statement calls shuffle() with the same with clause that
// rsort() took.
// Icarus Verilog 13.0 does not support the with clause of array methods
// and reports syntax errors on it, also on the legal call, which do not
// count. The 5.054 release of Verilator rejects the line because a with
// clause is not legal on the method.

module test_illegal_shuffle_with_clause;
  int q [$] = '{2, 3, 1};
  initial begin
    q.rsort() with (-item);
    $display("%0d %0d %0d", q[0], q[1], q[2]);
    q.shuffle();
    q.sort();
    $display("%0d %0d %0d %0d", q.size(), q[0], q[1], q[2]);
    q.shuffle() with (-item);   // illegal: shuffle() with a with clause
  end
endmodule
