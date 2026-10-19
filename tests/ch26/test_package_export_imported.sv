/*
:name: test_package_export_imported
:description: A package exports a name it imported from another package, so importing it makes that name visible (IEEE 1800-2023 Section 26.6)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.6 26.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_export_imported.expected
*/
// IEEE 1800-2023 §26.6: names a package imports from another package are not
// visible to those who import the first package, unless it exports them. Here
// pe_mid imports base_val from pe_base and exports it, so a module that imports
// pe_mid::* (26.3) can use base_val as well as the names declared in pe_mid.

package pe_base;
  int base_val = 5;
endpackage

package pe_mid;
  import pe_base::base_val;
  export pe_base::base_val;
  int mid_val = 6;
  function automatic int both();
    return base_val + mid_val;
  endfunction
endpackage

module test_package_export_imported;
  import pe_mid::*;

  initial $display("base_val=%0d mid_val=%0d both=%0d", base_val, mid_val, both());
endmodule
