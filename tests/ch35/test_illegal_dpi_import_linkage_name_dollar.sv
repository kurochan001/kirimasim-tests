/*
:name: test_illegal_dpi_import_linkage_name_dollar
:description: An explicit c_identifier of an import declaration shall be a C identifier, so one with a dollar sign is an error (IEEE 1800-2023 Section 35.5.4)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.4 35.4 5.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the explicit linkage name of an import contains a dollar sign, which a C identifier cannot
:expected_stderr_regex: test_illegal_dpi_import_linkage_name_dollar\.sv:23:
*/
// IEEE 1800-2023 §35.5.4: the linkage name of an imported subroutine, the
// c_identifier given before =, shall conform to C identifier syntax, and an
// error shall occur if it does not. c$add is a SystemVerilog identifier
// (5.6), but the $ makes it an invalid C identifier, so the import that
// names it is an error.
// Icarus Verilog 13.0 does not support DPI, so an error it reports on that
// line does not count.

module test_illegal_dpi_import_linkage_name_dollar;
  import "DPI-C" c$add = function int sv_add(input int a, input int b);   // illegal: not a C name

  initial $display("%0d", sv_add(1, 2));
endmodule
