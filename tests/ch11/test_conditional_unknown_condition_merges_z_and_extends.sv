/*
:name: test_conditional_unknown_condition_merges_z_and_extends
:description: with an x condition, integral branches that are not logically equivalent are extended to one width and merged bit by bit, a z bit against any other bit, or against z, giving x (IEEE 1800-2023 Section 11.4.11)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_conditional_unknown_condition_merges_z_and_extends.expected
*/
// IEEE 1800-2023 §11.4.11, Table 11-20: when the condition is x or z and the
// two integral branches are not logically equivalent, the result is built bit
// by bit: equal known bits are kept, every other pair, including any pair
// with a z on either side, gives x. The branches are first extended to the
// same width as for any operator (§11.6.1, §11.8.2), so a shorter unsigned
// branch gets zeros and a shorter signed branch, when both are signed, copies
// its sign bit.
// The first line pairs 0, 1, x, z with z and z with 0, 1, x in bits 7 to 2,
// and equal known bits 0 and 1 in bits 1 and 0, so it is xxxxxx01; a z
// condition gives the same. 4'b1100 against 8'b1111_1100 is zero-extended to
// 0000_1100 and differs in the upper bits (xxxx1100); with both signed it is
// sign-extended and equal to the other branch, which is returned whole;
// against an unsigned 8'b0000_1100 the signed 4'sb1100 is zero-extended and
// equal again. Two 4-bit branches in an 8-bit target are extended first, so
// the upper bits are 0.

module test_conditional_unknown_condition_merges_z_and_extends;
  logic cx = 1'bx;
  logic cz = 1'bz;
  logic [7:0] r8;

  initial begin
    r8 = cx ? 8'b01xz_zz01 : 8'bzzz0_1x01;
    $write("z pairs: %b", r8);
    r8 = cz ? 8'b01xz_zz01 : 8'bzzz0_1x01;
    $display(" %b", r8);
    r8 = cx ? 4'b1100 : 8'b1111_1100;
    $write("widths: %b", r8);
    r8 = cx ? 4'sb1100 : 8'sb1111_1100;
    $write(" %b", r8);
    r8 = cx ? 4'sb1100 : 8'b0000_1100;
    $write(" %b", r8);
    r8 = cx ? 4'b0011 : 4'b0101;
    $display(" %b", r8);
  end
endmodule
