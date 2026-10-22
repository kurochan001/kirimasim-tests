/*
:name: test_signed_unknown_extension_and_unsigned_padding
:description: Signed unknown sign bits extend while unsigned assignment zero fills (IEEE 1800-2023 Section 11.8.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.8.3 11.8.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_signed_unknown_extension_and_unsigned_padding.expected
*/
// IEEE 1800-2023 11.8.3 11.8.4: Width extension follows the source signedness
// after expression typing, including unknown or high impedance sign bits.
// Oracle checks: The 5.052 release is a two-state engine and is not used as the
// oracle here.

module test_signed_unknown_extension_and_unsigned_padding;
  logic signed [2:0] sx = 3'bx10, sz = 3'bz01;
  logic [2:0] ux = 3'bx10;
  logic [7:0] a, b, c;
  initial begin
    a = sx; b = sz; c = ux;
    $display("signed_x=%b signed_z=%b unsigned=%b", a, b, c);
  end
endmodule
