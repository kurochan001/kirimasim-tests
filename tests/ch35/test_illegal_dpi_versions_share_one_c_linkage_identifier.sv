/*
:name: test_illegal_dpi_versions_share_one_c_linkage_identifier
:description: Different DPI specification strings cannot use one C linkage identifier
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.4 35.5.4 A.2.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the two declarations of the single C linkage name use different DPI versions
:expected_stderr_regex: test_illegal_dpi_versions_share_one_c_linkage_identifier\.sv:17:(?:\d+:)?[^\n]*(?i:(?=[^\n]*shared_foreign)(?=[^\n]*(?:different|mismatch|inconsisten|conflict))(?=[^\n]*(?:DPI|version|specifier|linkage))[^\n]+)
:dpi_c: @test_illegal_dpi_versions_share_one_c_linkage_identifier.c
*/
module test_illegal_dpi_versions_share_one_c_linkage_identifier;
  import "DPI-C" shared_foreign = function void modern_alias(input bit [39:0] data);
  import "DPI" shared_foreign = function void legacy_alias(input bit [39:0] data); // illegal
endmodule
