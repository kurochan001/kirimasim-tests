/*
:name: test_illegal_reverse_with_clause
:description: a with clause on the array ordering method reverse() is a compilation error, while the same with clause on sort() is legal (IEEE 1800-2023 Section 7.12.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call of reverse() on the queue q has a with clause
:expected_stderr_regex: test_illegal_reverse_with_clause\.sv:33:
*/
// IEEE 1800-2023 §7.12.2: reverse() reverses the order of the elements of an
// array, and giving it a with clause shall be a compiler error. sort() may
// take a with clause whose expression gives the sort key.
// The legal design sorts q with the clause with (-item), which puts the
// elements in descending order of their values, and prints them: 3 2 1. It
// then calls reverse() without a with clause and prints q again: 1 2 3. The
// last statement calls reverse() with the same with clause that sort() took.
// Icarus Verilog 13.0 does not support the with clause of array methods
// and reports syntax errors on it, also on the legal call, which do not
// count. The 5.054 release of Verilator rejects the line because a with
// clause is not legal on the method.

module test_illegal_reverse_with_clause;
  int q [$] = '{1, 3, 2};
  initial begin
    q.sort() with (-item);
    $display("%0d %0d %0d", q[0], q[1], q[2]);
    q.reverse();
    $display("%0d %0d %0d", q[0], q[1], q[2]);
    q.reverse() with (-item);   // illegal: reverse() with a with clause
  end
endmodule
