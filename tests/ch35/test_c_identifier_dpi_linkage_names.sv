/*
:name: test_c_identifier_dpi_linkage_names
:description: An import declaration of a DPI function names the C function with a c_identifier, an identifier that starts with a letter or an underscore and continues with letters, digits and underscores; the C functions with those names are called through the imported functions and return 20 and 103 (IEEE 1800-2023 Sections 35.5.4 and 35.5.6 and footnote 54 of A.10)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 35.5.6 A.9.3 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_c_identifier_dpi_linkage_names.c
:expected_stdout: @test_c_identifier_dpi_linkage_names.expected
*/
// IEEE 1800-2023 footnote 54 of A.10: a c_identifier starts with a letter or
// an underscore, has at least one character and no spaces. A.9.3: a
// c_identifier is an identifier in the grammar of the C language. §35.5.4: the
// c_identifier in import "DPI-C" c_identifier = function ... gives the linkage
// name of the C function that the imported function calls, and §35.5.6 gives
// the types of its arguments and result. The test uses the C names _c_ident9,
// which starts with an underscore, and c_ident2, which starts with a letter;
// the C file defines those two functions, so a tool that resolves another name
// cannot link the test.
//
// f(2) calls _c_ident9(2), which returns 20, and g(3) calls c_ident2(3),
// which returns 103.
//
// Icarus Verilog 13.0 has no DPI; Verilator 5.052 produces this output.

module test_c_identifier_dpi_linkage_names;
  import "DPI-C" _c_ident9 = function int f(int a);
  import "DPI-C" c_ident2 = function int g(int a);

  initial $display("cident %0d %0d", f(2), g(3));
endmodule
