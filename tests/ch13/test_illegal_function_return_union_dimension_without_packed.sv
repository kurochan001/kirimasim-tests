/*
:name: test_illegal_function_return_union_dimension_without_packed
:description: a union written in a function return type with a packed dimension needs the packed keyword (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the return type of bad_word is a union with the packed dimension [3:0] but without the packed keyword
:expected_stderr_regex: test_illegal_function_return_union_dimension_without_packed\.sv:27:
*/
// IEEE 1800-2023 13.4 (Syntax 13-2, footnote 17): when a packed dimension
// follows a union written in place, the packed keyword shall be used as
// well, as for a structure. good_word returns union packed {...} [3:0],
// 32 bits, and is legal; bad_word has the same return type without packed.
// Its body is empty, which 13.4 allows, so nothing else depends on the type.
// Icarus Verilog 13.0 says on that line that it does not support unpacked
// structures, which is not this rule. The 5.054 release of Verilator reports
// this rule on the marked line (5.052 accepted the design).

module test_illegal_function_return_union_dimension_without_packed;
  function union packed { logic [7:0] u; logic signed [7:0] s; } [3:0] good_word();
    good_word = '0;
  endfunction
  function union { logic [7:0] u; logic signed [7:0] s; } [3:0] bad_word();   // illegal
  endfunction
  initial $display("%0d", $bits(good_word()));
endmodule
