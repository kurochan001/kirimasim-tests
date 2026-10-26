/*
:name: test_array_ranges_and_invalid_indices
:description: packed ranges accept descending, ascending and negative endpoints, an unpacked size means [0:size-1], and an invalid index reads the table value and writes nothing
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1 7.4.2 7.4.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_array_ranges_and_invalid_indices.expected
*/
// IEEE 1800-2023 7.4.1: every packed dimension is a two-endpoint constant
// range, and the first endpoint may be greater than, equal to or less than the
// second, negative and zero included. 7.4.2: a single positive constant in an
// unpacked dimension is a size and means [0:size-1]. 7.4.5: an out-of-bounds
// or x/z index is invalid; reading an unpacked array returns the value of
// Table 7-1 for its element type, writing performs no operation, and a packed
// array read returns x. The test uses descending, ascending and negative
// ranges, a size declaration, and reads and writes with out-of-bounds and
// x-valued indices.

module test_array_ranges_and_invalid_indices;
  logic [3:0] down;
  logic [0:3] up;
  logic [-1:2] neg;
  int fixed[3];
  int alt[-1:1];
  int idx;
  logic [3:0] xidx;

  initial begin
    down = 4'b1010;
    up = 4'b1010;
    neg = 4'b1010;
    $display("bits=%0d %0d %0d", $bits(down), $bits(up), $bits(neg));
    $display("up_edge=%b %b neg_edge=%b %b", up[0], up[3], neg[-1], neg[2]);
    fixed[0] = 10;
    fixed[1] = 11;
    fixed[2] = 12;
    $display("sizes=%0d %0d", $size(fixed), $size(alt));
    $display("alt_default=%0d %0d", $isunknown(alt[-1]), $isunknown(alt[1]));
    idx = 5;
    $display("oob_read=%0d", $isunknown(fixed[idx]));
    xidx = 4'bxxxx;
    $display("xz_read=%0d", $isunknown(fixed[xidx]));
    $display("packed_x=%b", down[idx]);
    fixed[idx] = 99;
    fixed[xidx] = 98;
    $display("after_bad_writes=%0d %0d %0d", $size(fixed), fixed[2], fixed[0]);
    down[idx] = 1'b1;
    $display("down=%b", down);
  end
endmodule
