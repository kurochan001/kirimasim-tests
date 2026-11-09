/*
:name: test_illegal_solve_before_size_state_array
:description: The size of a dynamic array that is not declared rand is no random variable and cannot appear in solve...before, while the size of a rand dynamic array can (IEEE 1800-2023 Section 18.5.9)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.9 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ordering constraint names s.size(), the size of the dynamic array s, which is not declared rand
:expected_stderr_regex: test_illegal_solve_before_size_state_array\.sv:32:
*/
// IEEE 1800-2023 §18.5.9: only random variables may be ordered, and the size
// of an array counts as one when the array is a rand dynamic array or queue
// (§18.4 lets the size of such an array be constrained and ordered). r is a
// rand dynamic array, so solve r.size() before x is legal. s is a dynamic
// array without rand: randomize() never changes its size, which acts as a
// state value in c, so solve s.size() before x names no random variable and
// is an error.
// Icarus Verilog 13.0 does not support constraints, so the syntax error it
// reports on line 32 does not count. The 5.052 release of Verilator rejects
// the parentheses after size in solve...before, also in the legal o1, so its
// error on line 32 does not count either.

class sbs_obj;
  rand int x;
  rand byte r[];
  byte s[] = '{1, 2};
  constraint c { r.size() inside {[1:4]}; x < 10; x >= s.size(); }
  constraint o1 { solve r.size() before x; }
  constraint o2 { solve s.size() before x; }   // illegal: s is not rand
endclass

module test_illegal_solve_before_size_state_array;
  sbs_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
