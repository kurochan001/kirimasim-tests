/*
:name: test_illegal_dpi_version_mismatch_across_package_and_module
:description: A package and a module cannot give the same external C identifier different DPI version strings even for identical scalar signatures
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.4 35.5.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the package and module import scalar_legacy_scope under different DPI version strings
:expected_stderr_regex: test_illegal_dpi_version_mismatch_across_package_and_module\.sv:(?:16|20):(?:\d+:)?[^\n]*(?i:(?=[^\n]*scalar_legacy_scope)(?=[^\n]*(?:different|mismatch|inconsisten|conflict))(?=[^\n]*(?:DPI|version|specifier|linkage))[^\n]+)
:dpi_c: @dpi_version_scope_controls.c
*/
package scope_of_legacy_version;
  import "DPI" scalar_legacy_scope = function int from_package(input int value);
endpackage

module test_illegal_dpi_version_mismatch_across_package_and_module;
  import "DPI-C" scalar_legacy_scope = function int from_module(input int value);
  initial $display("accepted: %0d %0d", scope_of_legacy_version::from_package(5), from_module(8));
endmodule
