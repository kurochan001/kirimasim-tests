/*
:name: test_illegal_disable_soft_parentheses_variable
:description: The primary of disable soft may end in parentheses only when it is an array built-in method such as size(), so disable soft x() on a rand int variable is an error (IEEE 1800-2023 Section 18.5.13.2)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.13.2 18.5.9 A.1.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the disable soft constraint writes x(), with parentheses after a rand variable that is not an array built-in method
:expected_stderr_regex: test_illegal_disable_soft_parentheses_variable\.sv:31:
*/
// IEEE 1800-2023 A.1.10 (Syntax 18-2, footnote 12, also shown with Syntax
// 18-8 in §18.5.9): disable soft takes a constraint primary, which may be
// followed by empty parentheses only when it is an array built-in method,
// such as size(). §18.5.13.2 allows the size of an array in disable soft. So
// disable soft q.size() and disable soft x are legal, and disable soft x(),
// with parentheses after the rand int x, is an error.
// Icarus Verilog 13.0 does not support disable soft, so the syntax error it
// reports on line 31 does not count. The 5.052 release of Verilator rejects
// the legal disable soft q.size() as well, so its syntax error on line 31 does
// not count either.

class dsp_obj;
  rand int x;
  rand byte q[$];
  constraint c_soft { soft x == 3; soft q.size() == 2; }
  constraint c_ok { disable soft q.size(); disable soft x; }
  constraint c_more { soft x inside {[1:2]}; }
  constraint c_bad { disable soft x(); }   // illegal: x is not an array method
endclass

module test_illegal_disable_soft_parentheses_variable;
  dsp_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
