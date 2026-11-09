/*
:name: test_illegal_solve_before_size_circular
:description: Ordering the size of a queue before a variable in one block and the variable before the size in another forms a circular ordering, which is an error (IEEE 1800-2023 Section 18.5.9)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.9 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: solve q.size() before x and solve x before q.size order the size of q and x in a circle
:expected_stderr_regex: test_illegal_solve_before_size_circular\.sv:(31|32):
*/
// IEEE 1800-2023 §18.5.9: the size of a rand queue may be ordered like a rand
// variable (array.size, with or without the parentheses, §18.4), and the
// orderings of a class shall not depend on each other in a circle. o1 orders
// q.size() before y and o2 orders q.size() before x; each is legal, and so is
// the pair. o3 orders x before q.size, the reverse of o2, which closes a
// circle between the size of q and x. A tool may report the error on o2 or on
// o3, which together form the circle.
// Icarus Verilog 13.0 does not support constraints, so the syntax errors it
// reports on these lines do not count. The 5.052 release of Verilator rejects
// the legal parentheses of q.size() in solve...before, so its error on line 31
// does not count either.

class sbz_obj;
  rand int x, y;
  rand byte q[$];
  constraint c { q.size() inside {[1:4]}; x == q.size(); y > x; }
  constraint o1 { solve q.size() before y; }
  constraint o2 { solve q.size() before x; }
  constraint o3 { solve x before q.size; }   // illegal: reverses o2
endclass

module test_illegal_solve_before_size_circular;
  sbz_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
