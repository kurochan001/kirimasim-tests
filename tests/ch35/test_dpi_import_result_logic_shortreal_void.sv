/*
:name: test_dpi_import_result_logic_shortreal_void
:description: An imported function can return a scalar logic value, including z and x, a shortreal, or nothing as a void function called as a statement (IEEE 1800-2023 Section 35.5.5)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.5 H.7.4 H.8.9 H.10.1.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_dpi_import_result_logic_shortreal_void.c
:expected_stdout: @test_dpi_import_result_logic_shortreal_void.expected
*/
// IEEE 1800-2023 §35.5.5: the result of an imported function may be void,
// a shortreal or a scalar logic value, among the other small types. H.7.4,
// H.8.9: a logic result is an svLogic, whose values sv_0, sv_1, sv_z and sv_x
// (H.10.1.1) stand for 0, 1, z and x, and a shortreal result is a C float.
// dpi_logic_of returns the four logic values for the codes 0 to 3,
// dpi_quarter returns n / 4 as a float, and dpi_store, a void function called
// as a statement, keeps its argument, which dpi_load returns. Icarus Verilog
// 13.0 has no DPI, and Verilator 5.052, a two-state simulator, turns the z
// and x results into 0 and 1.

module test_dpi_import_result_logic_shortreal_void;
  import "DPI-C" function logic dpi_logic_of(input int code);
  import "DPI-C" function shortreal dpi_quarter(input int n);
  import "DPI-C" function void dpi_store(input int v);
  import "DPI-C" function int dpi_load();

  initial begin
    logic l0, l1, lz, lx;
    shortreal s;
    l0 = dpi_logic_of(0);
    l1 = dpi_logic_of(1);
    lz = dpi_logic_of(2);
    lx = dpi_logic_of(3);
    $display("logic results: %b %b %b %b", l0, l1, lz, lx);
    s = dpi_quarter(5);
    $display("shortreal result: %0.2f", s);
    dpi_store(42);
    $display("void function kept %0d", dpi_load());
  end
endmodule
