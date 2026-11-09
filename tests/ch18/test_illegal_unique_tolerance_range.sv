/*
:name: test_illegal_unique_tolerance_range
:description: A uniqueness constraint takes only variables, so a tolerance range [b +/- 1] in its list is an error, although the same range is legal in an inside constraint (IEEE 1800-2023 Section 18.5.4)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.4 11.4.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the uniqueness group of bad contains the tolerance range [b +/- 1], which is not a variable
:expected_stderr_regex: test_illegal_unique_tolerance_range\.sv:27:
*/
// IEEE 1800-2023 §18.5.4 (Syntax 18-4, footnote 13): the list of unique is
// written as a range_list, whose items include the tolerance ranges of
// §11.4.13, but each item shall be an expression that denotes a singular
// variable or an unpacked array variable (or a slice of one). The constraint
// ok holds unique {a, b} and c inside {[b +/- 1]}, both legal; bad puts the
// range [b +/- 1] into the unique list, which is an error.
// Icarus Verilog 13.0 does not support constraints, and the 5.052 release
// of Verilator does not support the tolerance ranges, so the errors they
// report on the marked line do not count.

class utr_obj;
  rand bit [3:0] a, b, c;
  constraint ok { unique {a, b}; c inside {[b +/- 1]}; }
  constraint bad { unique {a, [b +/- 1]}; }   // illegal: a range is not a variable
endclass

module test_illegal_unique_tolerance_range;
  utr_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
