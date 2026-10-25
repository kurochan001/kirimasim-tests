/*
:name: test_illegal_solve_before_parentheses
:description: Parentheses after a variable in solve...before that is not an array method are an error (IEEE 1800-2023 Section 18.5.9)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ordering constraint writes y(), with parentheses after a rand variable that is not an array built-in method
:expected_stderr_regex: test_illegal_solve_before_parentheses\.sv:28:
*/
// IEEE 1800-2023 §18.5.9 (Syntax 18-8, footnote 12): a constraint_primary of
// solve...before can be followed by parentheses only when it is an array
// built-in method, such as size(). solve q.size() before x is legal; in
// solve x before y(), y is a rand int variable.
// Icarus Verilog 13.0 does not support constraints, so the syntax error it
// reports does not count. Verilator 5.052 also rejects the legal q.size() with
// parentheses in solve...before, so its error on that line does not count
// either.

class sbp_obj;
  rand int x, y;
  rand byte q[];
  constraint c { q.size() inside {[1:4]}; x < y; }
  constraint o1 { solve q.size() before x; }
  constraint o2 { solve x before y(); }   // illegal: y is not an array method
endclass

module test_illegal_solve_before_parentheses;
  sbp_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
