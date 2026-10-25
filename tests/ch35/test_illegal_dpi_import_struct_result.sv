/*
:name: test_illegal_dpi_import_struct_result
:description: The result of an imported function is restricted to the small types, so an unpacked struct result is an error (IEEE 1800-2023 Section 35.5.4)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.4 35.5.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an imported function returns an unpacked struct, which is not one of the permitted result types
:expected_stderr_regex: test_illegal_dpi_import_struct_result\.sv:28:
*/
// IEEE 1800-2023 §35.5.4: footnote 26 of Syntax 35-1 restricts the return
// types of imported functions to small values (35.5.5): void, byte,
// shortint, int, longint, real, shortreal, chandle, string and scalar bit
// and logic. c_make returns the unpacked struct pair_t, which is not one of
// them.
// Icarus Verilog 13.0 does not support DPI, so an error it reports on that
// line does not count. Verilator 5.052 stops with an internal fault.

module test_illegal_dpi_import_struct_result;
  typedef struct {
    int a;
    int b;
  } pair_t;

  import "DPI-C" function pair_t c_make();   // illegal: struct result

  initial begin
    pair_t p;
    p = c_make();
    $display("%0d", p.a);
  end
endmodule
