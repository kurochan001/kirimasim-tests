/*
:name: test_illegal_function_return_struct_dimension_without_packed
:description: a structure written in a function return type with a packed dimension needs the packed keyword (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the return type of bad_pair is a structure with the packed dimension [1:0] but without the packed keyword
:expected_stderr_regex: test_illegal_function_return_struct_dimension_without_packed\.sv:27:
*/
// IEEE 1800-2023 13.4 (Syntax 13-2, footnote 17): when a packed dimension
// follows a structure or union written in place, the packed keyword shall be
// used as well. good_pair returns struct packed {...} [1:0], 16 bits, and is
// legal; bad_pair has the same return type without packed. Its body is
// empty, which 13.4 allows, so nothing else depends on the type.
// Icarus Verilog 13.0 says on that line that it does not support unpacked
// structures, which is not this rule. The 5.054 release of Verilator reports
// this rule on the marked line (5.052 accepted the design).

module test_illegal_function_return_struct_dimension_without_packed;
  function struct packed { logic [3:0] hi; logic [3:0] lo; } [1:0] good_pair();
    good_pair = '0;
  endfunction
  function struct { logic [3:0] hi; logic [3:0] lo; } [1:0] bad_pair();   // illegal
  endfunction
  initial $display("%0d", $bits(good_pair()));
endmodule
