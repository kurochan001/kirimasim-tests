/*
:name: test_packed_array_whole_element_part_sign
:description: a signed packed array is signed as a whole while its elements are unsigned unless their named type is signed, a part-select is unsigned, and signed on an unpacked array applies to its elements (IEEE 1800-2023 Sections 7.4.1, 7.4.6)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1 7.4.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_array_whole_element_part_sign.expected
*/
// IEEE 1800-2023 §7.4.1: when a packed array is declared signed, the array
// seen as one vector is signed, but its elements are unsigned unless they are
// of a named type declared signed; a part-select of a packed array is unsigned.
// §7.4.6: signed on an unpacked array applies to each element, since the whole
// array is not one vector.
// Every value below is widened to int (assignment, §10.7), which extends a
// signed value with its sign bit and an unsigned one with zeros, and is also
// compared with 0. sw is signed as a whole with unsigned 4-bit elements; se is
// an unsigned array of elements of the signed type snib_t; sv is a signed
// vector read whole and through part-selects; ua is an unpacked array of
// signed elements.

module test_packed_array_whole_element_part_sign;
  typedef logic signed [3:0] snib_t;

  logic signed [1:0][3:0] sw;
  snib_t [1:0] se;
  logic signed [7:0] sv;
  logic signed [3:0] ua [0:1];
  int whole, hi, lo;

  initial begin
    sw = 8'hf6;
    se = 8'hf6;
    sv = 8'hf6;
    ua[0] = 4'hf;
    ua[1] = 4'h7;

    whole = sw; hi = sw[1]; lo = sw[0];
    $display("sw: whole=%0d [1]=%0d [0]=%0d; <0: whole=%0d [1]=%0d", whole, hi, lo,
             sw < 0, sw[1] < 0);
    whole = se; hi = se[1]; lo = se[0];
    $display("se: whole=%0d [1]=%0d [0]=%0d; <0: whole=%0d [1]=%0d", whole, hi, lo,
             se < 0, se[1] < 0);
    whole = sv; hi = sv[7:0]; lo = sv[7:4];
    $display("sv: whole=%0d [7:0]=%0d [7:4]=%0d; <0: whole=%0d [7:0]=%0d", whole, hi, lo,
             sv < 0, sv[7:0] < 0);
    hi = ua[0]; lo = ua[1];
    $display("ua: [0]=%0d [1]=%0d; <0: [0]=%0d [1]=%0d", hi, lo, ua[0] < 0, ua[1] < 0);
  end
endmodule
