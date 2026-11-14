/*
:name: test_illegal_dpi_export_class_formal
:description: An exported function follows the formal argument type rules of imported functions, so exporting a function with a formal of class type is an error (IEEE 1800-2023 Section 35.7)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.7 35.5.6 35.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an exported function has a formal argument of class type, which cannot cross the DPI boundary
:expected_stderr_regex: test_illegal_dpi_export_class_formal\.sv:(39|45):
*/
// IEEE 1800-2023 §35.7: an exported function has to meet the restrictions
// on argument and result types that apply to imported functions, and
// exporting one that does not is an error. §35.5.6 lists the only types a
// formal argument of an imported or exported subroutine can have, and
// §35.2.2 says that only a subset of the SystemVerilog types crosses the
// boundary. A class type is not in that list.
//
// sv_read_int has an int formal and is exported legally. sv_read_box has
// the same result but a formal of the class type c_box, so its export
// declaration is an error. A tool can report it at the export declaration
// or at the formal of the function, so both lines are accepted. Without
// that export declaration the design is legal: sv_read_box stays an
// ordinary SystemVerilog function.
//
// Icarus Verilog 13.0 has no DPI and rejects both export declarations as
// syntax errors, so its error does not count. The 5.054 release of
// the Verilator simulator rejects the class formal as an unsupported DPI
// argument type, not as a breach of this rule, so it is not counted either.

module test_illegal_dpi_export_class_formal;
  class c_box;
    int v;
  endclass

  export "DPI-C" function sv_read_int;
  export "DPI-C" function sv_read_box;

  function int sv_read_int(input int v);
    return v + 1;
  endfunction

  function int sv_read_box(input c_box b);
    return b.v + 1;
  endfunction

  initial begin
    c_box b;
    b = new;
    b.v = 4;
    $display("%0d %0d", sv_read_int(2), sv_read_box(b));
  end
endmodule
