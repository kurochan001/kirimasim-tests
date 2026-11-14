/*
:name: test_illegal_dpi_export_dynamic_array_formal
:description: An exported function cannot have a formal argument of a dynamic array type, the [] form that only an imported function can use as an open array (IEEE 1800-2023 Section 35.5.6)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.6 35.5.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an exported function has a formal argument of a dynamic array type
:expected_stderr_regex: test_illegal_dpi_export_dynamic_array_formal\.sv:(33|35):
*/
// IEEE 1800-2023 §35.5.6: in an exported DPI subroutine it is an error to
// declare a formal argument of a dynamic array type. §35.5.6.1: a formal
// whose unpacked dimension is written [] is an open array, which imported
// functions may have and exported functions may not.
//
// The imported function c_total has the open array formal int a[], which is
// legal. The SystemVerilog function sv_total has a formal of the same form,
// which in a SystemVerilog function is a dynamic array, and it is exported.
// A tool can report the error at the export declaration or at the formal of
// the function, so both lines are accepted. Without the export declaration
// the design is legal.
//
// Icarus Verilog 13.0 has no DPI, so an error it reports on those lines does
// not count. The 5.054 release of Verilator reports the formal of sv_total
// as an unsupported DPI argument type, not as a breach of this rule, so it
// is not counted either.

module test_illegal_dpi_export_dynamic_array_formal;
  import "DPI-C" function int c_total(input int a[]);
  export "DPI-C" function sv_total;

  function int sv_total(input int a[]);
    int s;
    s = 0;
    foreach (a[i]) s += a[i];
    return s;
  endfunction

  initial begin
    int d[];
    d = '{1, 2, 3};
    $display("%0d %0d", c_total(d), sv_total(d));
  end
endmodule
