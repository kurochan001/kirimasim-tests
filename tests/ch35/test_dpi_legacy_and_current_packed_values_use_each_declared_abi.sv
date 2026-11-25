/*
:name: test_dpi_legacy_and_current_packed_values_use_each_declared_abi
:description: Current DPI uses canonical vectors while the legacy declaration transfers opaque packed objects
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 H.2 H.14 C.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_dpi_legacy_and_current_packed_values_use_each_declared_abi.expected
:dpi_c: @test_dpi_legacy_and_current_packed_values_use_each_declared_abi.c
*/
module test_dpi_legacy_and_current_packed_values_use_each_declared_abi;
  import "DPI-C" function void modern_transfer(input bit [64:0] a, input logic [64:0] b,
                                              output bit [64:0] x, output logic [64:0] y);
  import "DPI" function void legacy_transfer(input bit [64:0] a, input logic [64:0] b,
                                             output bit [64:0] x, output logic [64:0] y);

  bit [64:0] plain = 65'h1_2718_2818_3141_5926;
  logic [64:0] stateful = 65'h1_0123_4567_89ab_cxzf;
  bit [64:0] modern_plain, legacy_plain;
  logic [64:0] modern_stateful, legacy_stateful;

  initial begin
    modern_transfer(plain, stateful, modern_plain, modern_stateful);
    legacy_transfer(plain, stateful, legacy_plain, legacy_stateful);
    $display("modern round trip=%0d legacy round trip=%0d",
             (modern_plain == plain && modern_stateful === stateful),
             (legacy_plain == plain && legacy_stateful === stateful));

    // Keep the low bit-vector words and the unknown mask unchanged.
    // Swap X and Z and clear the high bit in both inputs.
    plain = 65'h0_2718_2818_3141_5926;
    stateful = 65'h0_0123_4567_89ab_czxf;
    legacy_transfer(plain, stateful, legacy_plain, legacy_stateful);
    modern_transfer(plain, stateful, modern_plain, modern_stateful);
    $display("second round trip modern=%0d legacy=%0d",
             (modern_plain == plain && modern_stateful === stateful),
             (legacy_plain == plain && legacy_stateful === stateful));
  end
endmodule
