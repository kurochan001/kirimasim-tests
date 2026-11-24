/*
:name: test_vpi_name_lookup_excludes_imports_and_compilation_unit_values
:description: VPI name lookup sees module and package declarations while excluding imported and unit names
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.10 38.21
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_name_lookup_excludes_imports_and_compilation_unit_values.expected
:vpi_c: @test_vpi_name_lookup_excludes_imports_and_compilation_unit_values.c
*/
package lookup_namespace;
  int imported_data = 31;
endpackage

int unit_data = 52;

module test_vpi_name_lookup_excludes_imports_and_compilation_unit_values;
  import lookup_namespace::imported_data;
  int module_data = 63;

  initial begin
    $display("SV sees=%0d/%0d/%0d", module_data, imported_data, $unit::unit_data);
    $vt_check_visible_names;
  end
endmodule
