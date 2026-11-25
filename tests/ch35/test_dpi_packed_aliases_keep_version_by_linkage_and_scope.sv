/*
:name: test_dpi_packed_aliases_keep_version_by_linkage_and_scope
:description: Packed DPI arguments use the shared linkage version across package and module aliases
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.4 H.14
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_dpi_packed_aliases_keep_version_by_linkage_and_scope.expected
:expected_exit: 0
:dpi_c: @test_dpi_legacy_and_current_packed_values_use_each_declared_abi.c
*/
package packed_alias_package;
  import "DPI" legacy_transfer = function void legacy_from_package(
    input bit [64:0] plain, input logic [64:0] stateful,
    output bit [64:0] plain_out, output logic [64:0] stateful_out
  );
  import "DPI-C" modern_transfer = function void modern_from_package(
    input bit [64:0] plain, input logic [64:0] stateful,
    output bit [64:0] plain_out, output logic [64:0] stateful_out
  );
endpackage

module test_dpi_packed_aliases_keep_version_by_linkage_and_scope;
  import "DPI" legacy_transfer = function void legacy_from_module(
    input bit [64:0] plain, input logic [64:0] stateful,
    output bit [64:0] plain_out, output logic [64:0] stateful_out
  );
  import "DPI-C" modern_transfer = function void modern_from_module(
    input bit [64:0] plain, input logic [64:0] stateful,
    output bit [64:0] plain_out, output logic [64:0] stateful_out
  );

  localparam bit [64:0] PACKAGE_BITS = 65'h1_2718_2818_3141_5926;
  localparam logic [64:0] PACKAGE_LOGIC = 65'h1_0123_4567_89ab_cxzf;
  localparam bit [64:0] MODULE_BITS = 65'h0_1414_2135_6237_3095;
  localparam logic [64:0] MODULE_LOGIC = 65'h0_7654_3210_01zx_4567;
  bit [64:0] plain_out;
  logic [64:0] stateful_out;

  initial begin
    packed_alias_package::legacy_from_package(PACKAGE_BITS, PACKAGE_LOGIC, plain_out, stateful_out);
    $display("package legacy=%0d", plain_out == PACKAGE_BITS && stateful_out === PACKAGE_LOGIC);
    plain_out = '0;
    stateful_out = '0;
    packed_alias_package::modern_from_package(PACKAGE_BITS, PACKAGE_LOGIC, plain_out, stateful_out);
    $display("package current=%0d", plain_out == PACKAGE_BITS && stateful_out === PACKAGE_LOGIC);
    plain_out = '0;
    stateful_out = '0;
    legacy_from_module(MODULE_BITS, MODULE_LOGIC, plain_out, stateful_out);
    $display("module legacy=%0d", plain_out == MODULE_BITS && stateful_out === MODULE_LOGIC);
    plain_out = '0;
    stateful_out = '0;
    modern_from_module(MODULE_BITS, MODULE_LOGIC, plain_out, stateful_out);
    $display("module current=%0d", plain_out == MODULE_BITS && stateful_out === MODULE_LOGIC);
  end
endmodule
