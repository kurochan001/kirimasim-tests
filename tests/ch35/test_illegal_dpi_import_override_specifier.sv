/*
:name: test_illegal_dpi_import_override_specifier
:description: The dynamic override specifiers of a function prototype are legal only on methods of a class that is not an interface class, so an import declaration in a module cannot have them (IEEE 1800-2023 Section 35.5.4)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.4 8.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an import declaration in a module has the dynamic override specifier :initial
:expected_stderr_regex: test_illegal_dpi_import_override_specifier\.sv:23:
*/
// IEEE 1800-2023 §35.5.4: footnote 25 of Syntax 35-1 says that the
// dynamic_override_specifiers of a function prototype, such as :initial
// (8.20), shall only be legal on method declarations inside a class that is
// not an interface class. The import declaration c_f in a module has
// :initial, which is an error.
// Icarus Verilog 13.0 does not support DPI, so an error it reports on that
// line does not count. Verilator 5.052 accepts the design.

module test_illegal_dpi_import_override_specifier;
  import "DPI-C" function :initial int c_f();   // illegal: override specifier outside a class

  initial $display("%0d", c_f());
endmodule
