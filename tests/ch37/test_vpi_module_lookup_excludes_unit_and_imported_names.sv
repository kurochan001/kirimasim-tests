/*
:name: test_vpi_module_lookup_excludes_unit_and_imported_names
:description: VPI looks up module declarations without treating imported and compilation unit names as module members
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.10 38.21
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_module_lookup_excludes_unit_and_imported_names.expected
:vpi_c: @test_vpi_module_lookup_excludes_unit_and_imported_names.c
*/
int unit_only = 11;
package visible_pkg;
  int imported = 19;
endpackage

module test_vpi_module_lookup_excludes_unit_and_imported_names;
  import visible_pkg::imported;
  int actual_member;
  initial begin
    actual_member = unit_only + imported;
    #1 $display("source_sum=%0d", actual_member);
  end
endmodule
