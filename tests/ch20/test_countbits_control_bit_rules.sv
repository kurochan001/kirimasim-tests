/*
:name: test_countbits_control_bit_rules
:description: each control bit of $countbits is a 1-bit logic value, so only the LSB of a wider value counts, a value given twice counts once, and the control bits may be variables (IEEE 1800-2023 Section 20.9)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_countbits_control_bit_rules.expected
*/
// IEEE 1800-2023 §20.9: $countbits(e, c, ...) returns the number of bits of e
// whose value equals one of the control bits. A control bit has the type
// 1-bit logic: of a wider value only the LSB is used, and a value that
// appears more than once is counted as if it appeared once. The control bits
// may be variables.
// v has five 1 bits, three 0 bits, two x bits and one z bit, so every set of
// control values gives a different count. Line 1 uses constants: '1 (5);
// 2'b01 (LSB 1, 5); 2'b10 and 4'b1110 (LSB 0, 3); '1 twice (5); 1'b0 and
// 3'b110 (both 0, 3); 'x and 2'b1x (both x, 2); 'z and 'x (3); all four
// values (11); 3'b01z (LSB z, 1). Line 2 passes a 1-bit variable set to 1,
// x, z and 0 in turn and a 2-bit variable set to 2'b10 and 2'b0z.
// Neither simulator follows the clause here: the vvp of Icarus Verilog 13.0
// stops on an internal assertion for a control value wider than 1 bit, and
// release 5.052 of the Verilator tool does not support more than 3 control
// bits.

module test_countbits_control_bit_rules;
  logic [10:0] v = 11'b1x0_x111_0z10;
  logic c;
  logic [1:0] c2;
  int n1, nx, nz, n0, w0, wz;

  initial begin
    $display("%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d", $countbits(v, '1), $countbits(v, 2'b01),
             $countbits(v, 2'b10), $countbits(v, 4'b1110), $countbits(v, '1, '1),
             $countbits(v, 1'b0, 3'b110), $countbits(v, 'x, 2'b1x), $countbits(v, 'z, 'x),
             $countbits(v, '1, '0, 'x, 'z), $countbits(v, 3'b01z));
    c = 1'b1;
    n1 = $countbits(v, c);
    c = 1'bx;
    nx = $countbits(v, c);
    c = 1'bz;
    nz = $countbits(v, c);
    c = 1'b0;
    n0 = $countbits(v, c);
    c2 = 2'b10;
    w0 = $countbits(v, c2);
    c2 = 2'b0z;
    wz = $countbits(v, c2);
    $display("%0d %0d %0d %0d %0d %0d", n1, nx, nz, n0, w0, wz);
  end
endmodule
