/*
:name: test_package_export_named_wildcard
:description: export pkg::* re-exports only the names that a package imported from that one package, not names imported from another package (IEEE 1800-2023 Section 26.5)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.5 26.6 26.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_export_named_wildcard.expected
*/
// IEEE 1800-2023 §26.5: "export ew_g::*;" exports every name that the package
// imported from ew_g, while names it imported from other packages and does not
// export stay its own. §26.6: a module that imports the middle package gets
// ga, gb and gsum that the export makes visible, and gm that the package
// declares. The test does not name go, which the middle package imports but
// does not export, so the reference stays legal (26.3). Icarus Verilog 13.0
// does not bind the names of a named wildcard export, so the expected output
// is recorded with Verilator 5.052.

package ew_g;
  int ga = 1;
  int gb = 2;

  function automatic int gsum();
    return ga + gb;
  endfunction
endpackage

package ew_other;
  int go = 9;
endpackage

package ew_mid;
  import ew_g::*;
  import ew_other::go;

  export ew_g::*;

  int gm = 3;
endpackage

module test_package_export_named_wildcard;
  import ew_mid::*;

  initial $display("ga=%0d gb=%0d gm=%0d gsum=%0d", ga, gb, gm, gsum());
endmodule
