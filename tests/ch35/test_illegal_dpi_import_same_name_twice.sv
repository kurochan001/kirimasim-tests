/*
:name: test_illegal_dpi_import_same_name_twice
:description: Two import declarations cannot define the same SystemVerilog subroutine name in one scope, even with different C linkage names (IEEE 1800-2023 Section 35.5.4)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.4 35.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: two import declarations in one module define the subroutine name c_one
:expected_stderr_regex: test_illegal_dpi_import_same_name_twice\.sv:(24|25):
*/
// IEEE 1800-2023 §35.5.4: an import declaration defines a subroutine of its
// name in the scope where it occurs, so several imports of the same
// subroutine name into one scope are forbidden (also 35.2.1: a name can be
// defined only once per scope). Both imports here define c_one in the
// module, the second one with the linkage name c_two; a tool can report
// either declaration.
// Icarus Verilog 13.0 does not support DPI, so an error it reports on these
// lines does not count.

module test_illegal_dpi_import_same_name_twice;
  import "DPI-C" function int c_one(input int a);   // c_one defined here
  import "DPI-C" c_two = function int c_one(input int a);   // illegal: c_one again

  initial $display("%0d", c_one(1));
endmodule
