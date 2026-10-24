/*
:name: test_dpi_import_formal_names_defaults
:description: Declarations of the same C function in a package and in a module may give its formal arguments different names and different default values, and each call binds by the names and defaults of the declaration it uses (IEEE 1800-2023 Section 35.5.4)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 35.4 35.6 13.5.3 13.5.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_import_formal_names_defaults.c
:expected_stdout: @test_dpi_import_formal_names_defaults.expected
*/
// IEEE 1800-2023 §35.5.4: the same imported subroutine may be declared in
// several scopes with the same type signature, and the argument names and
// default values of the declarations may differ; formal argument names are
// needed only for binding by name. The C function dpi_mix(a, b) returns
// a * 100 + b. The package declares it with the names a and b and the
// default b = 2; the module declares it as mix_xy with the names x and y and
// the defaults 5 and 7 (35.4: dpi_mix is the linkage name). Calls use
// defaults (13.5.3) and binding by name (13.5.4) with the names of each
// declaration. Icarus Verilog 13.0 has no DPI.

package test_dpi_import_formal_names_defaults_pkg;
  import "DPI-C" function int dpi_mix(input int a, input int b = 2);
endpackage

module test_dpi_import_formal_names_defaults;
  import "DPI-C" dpi_mix = function int mix_xy(input int x = 5, input int y = 7);

  initial begin
    $display("package, by name: %0d", test_dpi_import_formal_names_defaults_pkg::dpi_mix(.b(3),
                                                                                        .a(10)));
    $display("package, default b: %0d", test_dpi_import_formal_names_defaults_pkg::dpi_mix(4));
    $display("module, by name y: %0d", mix_xy(.y(1)));
    $display("module, all defaults: %0d", mix_xy());
  end
endmodule
