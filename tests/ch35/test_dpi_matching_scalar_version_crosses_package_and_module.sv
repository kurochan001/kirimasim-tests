/*
:name: test_dpi_matching_scalar_version_crosses_package_and_module
:description: Separate external identifiers can use different DPI versions while declarations of each identifier agree across scopes
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.4 35.5.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dpi_matching_scalar_version_crosses_package_and_module.expected
:dpi_c: @dpi_version_scope_controls.c
*/
package first_version_scope;
  import "DPI" scalar_legacy_scope = function int from_legacy_package(input int value);
  import "DPI-C" scalar_current_scope = function int from_current_package(input int value);
endpackage

module test_dpi_matching_scalar_version_crosses_package_and_module;
  import "DPI" scalar_legacy_scope = function int legacy_here(input int value);
  import "DPI-C" scalar_current_scope = function int current_here(input int value);
  initial begin
    $display("legacy=%0d %0d",
             first_version_scope::from_legacy_package(5), legacy_here(8));
    $display("current=%0d %0d",
             first_version_scope::from_current_package(5), current_here(8));
  end
endmodule
