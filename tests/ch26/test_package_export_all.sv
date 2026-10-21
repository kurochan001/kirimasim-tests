/*
:name: test_package_export_all
:description: export *::* re-exports every name a package imports from every package (IEEE 1800-2023 Section 26.5)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.5 26.6 26.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_export_all.expected
*/
// IEEE 1800-2023 §26.5: "export *::*;" exports every name that the package
// imported with a wildcard import, from every package. §26.6: a package that
// imports mid_pkg therefore sees base_x and twice, which mid_pkg imported from
// base_pkg, as well as mid_y, which mid_pkg declares. §26.3: the import in the
// module makes those names visible without a scope. Icarus Verilog 13.0 does
// not bind the re-exported names.

package base_pkg;
  int base_x = 3;

  function automatic int twice(int v);
    return 2 * v;
  endfunction
endpackage

package mid_pkg;
  import base_pkg::*;
  export *::*;

  int mid_y = 4;
endpackage

module test_package_export_all;
  import mid_pkg::*;

  initial $display("x=%0d y=%0d twice=%0d", base_x, mid_y, twice(5));
endmodule
