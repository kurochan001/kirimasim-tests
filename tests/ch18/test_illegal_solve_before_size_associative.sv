/*
:name: test_illegal_solve_before_size_associative
:description: The size of an associative array is not randomizable, so it cannot be ordered in solve...before even when the array is declared rand, while the size of a rand queue can (IEEE 1800-2023 Section 18.5.9)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.9 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ordering constraint names aa.size(), the size of an associative array, which is not a random variable
:expected_stderr_regex: test_illegal_solve_before_size_associative\.sv:33:
*/
// IEEE 1800-2023 §18.4: of a rand array, only the size of a dynamic array or
// queue is randomizable and may appear in solve...before; the size and the
// indices of an associative array are not randomizable, only its elements
// are. §18.5.9: only random variables may be ordered. So solve q.size()
// before x, with the rand queue q, is legal, but aa.size() names no random
// variable although aa is declared rand, and the ordering o2 is an error.
// The standard has no example of this case; the error follows from the two
// rules together.
// Icarus Verilog 13.0 does not support constraints, so the syntax error it
// reports on line 33 does not count. The 5.052 release of Verilator rejects
// the parentheses after size in solve...before, also in the legal o1, so its
// error on line 33 does not count either.

class sba_obj;
  rand int x;
  rand byte q[$];
  rand byte aa[int];
  constraint c { q.size() inside {[1:4]}; x < 10; x >= q.size(); }
  constraint o1 { solve q.size() before x; }
  constraint o2 { solve aa.size() before x; }   // illegal: not randomizable
endclass

module test_illegal_solve_before_size_associative;
  sba_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
