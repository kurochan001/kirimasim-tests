/*
:name: test_illegal_dpi_import_c_type_name
:description: Only SystemVerilog data types cross the DPI boundary, so an import declaration that names the C type char for a formal argument is an error, while the same declaration with the SystemVerilog type byte is legal (IEEE 1800-2023 Section 35.2.2)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.2.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a formal argument of an import declaration has the C type char, which is not a SystemVerilog data type
:expected_stderr_regex: test_illegal_dpi_import_c_type_name\.sv:32:
*/
// IEEE 1800-2023 §35.2.2: the data types that cross the boundary between
// SystemVerilog and the foreign language are SystemVerilog data types only.
// A design cannot import a type from the other language or write a formal
// with that language's type syntax; the import declaration is written in
// SystemVerilog types, and the C side sees their DPI mapping.
//
// c_upper takes a byte, the SystemVerilog type whose C counterpart is char,
// and is legal. c_lower names the C type char itself for its formal. No
// type char exists in SystemVerilog, since char is not a keyword and the
// design declares no such type, so that declaration is an error. With byte
// in place of char the design is legal.
//
// Icarus Verilog 13.0 has no DPI and rejects both import declarations as
// syntax errors, so its error does not count. The 5.054 release of
// the Verilator simulator reports that it cannot find a type char.

module test_illegal_dpi_import_c_type_name;
  import "DPI-C" function byte c_upper(input byte c);
  import "DPI-C" function byte c_lower(input char c);

  initial $display("%0d %0d", c_upper(8'd97), c_lower(8'd65));
endmodule
