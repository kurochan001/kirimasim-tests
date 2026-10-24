/*
:name: test_illegal_dpi_import_default_linkage_dollar
:description: Without a c_identifier the linkage name of an import is its SystemVerilog name, which then shall be a C identifier, so a name with a dollar sign is an error (IEEE 1800-2023 Section 35.5.4)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.4 35.4 5.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the name of an imported function, used as its linkage name, contains a dollar sign
:expected_stderr_regex: test_illegal_dpi_import_default_linkage_dollar\.sv:23:
*/
// IEEE 1800-2023 §35.5.4: when an import declaration gives no c_identifier,
// its linkage name is the SystemVerilog name of the subroutine, which shall
// then conform to C identifier syntax too; an error shall occur if the name
// indirectly breaks it. sv$add is a legal SystemVerilog name (5.6) but not a
// C identifier.
// Icarus Verilog 13.0 does not support DPI, so an error it reports on that
// line does not count.

module test_illegal_dpi_import_default_linkage_dollar;
  import "DPI-C" function int sv$add(input int a, input int b);   // illegal: default name not C

  initial $display("%0d", sv$add(1, 2));
endmodule
