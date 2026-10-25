/*
:name: test_onehot_ignores_unknown_bits
:description: $onehot is true exactly when one bit of its argument is 1, whatever x and z bits it also has, and $onehot0 when at most one bit is 1 (IEEE 1800-2023 Section 20.9)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_onehot_ignores_unknown_bits.expected
*/
// IEEE 1800-2023 §20.9: $onehot(e) returns 1'b1 when $countbits(e, '1) == 1
// and 1'b0 otherwise, so x and z bits neither make it true nor false;
// $onehot0(e) returns 1'b1 when $countbits(e, '1) <= 1.
// Line 1 applies $onehot to 0100 and 0110 and 0000 (one, two and no 1
// bits), to 01x0 and z100 (one 1 bit beside x or z), to xx00 (no 1 bit,
// only x) and to 1x1z and xzxz. Line 2 applies $onehot0 to xz00 (no 1 bit),
// x1z0 (one) and 1x10 (two).

module test_onehot_ignores_unknown_bits;
  logic [3:0] a [8];

  initial begin
    a[0] = 4'b0100;
    a[1] = 4'b0110;
    a[2] = 4'b0000;
    a[3] = 4'b01x0;
    a[4] = 4'bz100;
    a[5] = 4'bxx00;
    a[6] = 4'b1x1z;
    a[7] = 4'bxzxz;
    $display("onehot: %b %b %b %b %b %b %b %b", $onehot(a[0]), $onehot(a[1]), $onehot(a[2]),
             $onehot(a[3]), $onehot(a[4]), $onehot(a[5]), $onehot(a[6]), $onehot(a[7]));
    $display("onehot0: %b %b %b", $onehot0(4'bxz00), $onehot0(4'bx1z0), $onehot0(4'b1x10));
  end
endmodule
