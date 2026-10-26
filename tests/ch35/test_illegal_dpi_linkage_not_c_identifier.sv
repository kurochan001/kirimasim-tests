/*
:name: test_illegal_dpi_linkage_not_c_identifier
:description: An escaped c_identifier loses its leading backslash and trailing white space and must then be a C identifier, so one that starts with a digit is an error (IEEE 1800-2023 Section 35.4)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.4 35.5.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the c_identifier \2bad becomes the linkage name 2bad, which does not start with a letter or underscore
:expected_stderr_regex: test_illegal_dpi_linkage_not_c_identifier\.sv:25:
*/
// IEEE 1800-2023 §35.4: a global name may be written as an escaped identifier;
// the leading backslash and the trailing white space are stripped to form the
// linkage identifier, which shall then follow the C rules: it starts with a
// letter or underscore and continues with letters, digits or underscores. An
// error shall occur when the c_identifier does not conform. The import of lnc_f
// gives the linkage name \2bad , which becomes 2bad.

// Icarus Verilog 13.0 has no DPI and rejects the import line, so
// it is not in :oracle:. Verilator 5.052 stops in the generated C++ code.

module test_illegal_dpi_linkage_not_c_identifier;
  import "DPI-C" \2bad = function int lnc_f(input int a);   // illegal: 2bad

  initial $display("%0d", lnc_f(1));
endmodule
