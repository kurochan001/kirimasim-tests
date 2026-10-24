/*
:name: test_real_ieee754_double_and_realtime
:description: real values have the IEEE 754 double format of a C double, bit for bit, and realtime is the same type as real (IEEE 1800-2023 Section 6.12)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12 6.13 20.5 6.23 35.5.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_real_ieee754_double_and_realtime.c
:expected_stdout: @test_real_ieee754_double_and_realtime.expected
*/
// IEEE 1800-2023 §6.12: real is the same as a C double, and realtime
// declarations are treated as real declarations; the footnote of 6.12 (shown
// with 6.13) says that real and shortreal are represented as IEEE Std 754
// describes. $realtobits (20.5) shows the bits of a value; shortreal is
// checked in test_shortreal_ieee754_single.
// For each value, the bits that $realtobits gives are shown and compared with
// the bits that C finds in the double it receives through DPI (35.5.6), and a
// double that C builds from bits is compared with the SystemVerilog value. The
// values include 0.1 + 0.2, which is not 0.3 in binary, the next double after
// 1.0, the largest double and the smallest subnormal one. A realtime variable
// keeps the same double, and type() shows that realtime and real are one type
// (6.23).

module test_real_ieee754_double_and_realtime;
  import "DPI-C" function longint rd_bits(input real x);
  import "DPI-C" function real rd_from_bits(input longint b);

  real vals[6];
  real r;
  realtime rt = 0.1;

  initial begin
    vals[0] = 1.0;
    vals[1] = -2.5;
    vals[2] = 0.1 + 0.2;
    vals[3] = 1.0 + 2.0 ** -52;
    vals[4] = 1.7976931348623157e308;
    vals[5] = 4.9e-324;
    foreach (vals[i])
      $display("%h same in C %0d", $realtobits(vals[i]), rd_bits(vals[i]) == $realtobits(vals[i]));
    $display("0.1 + 0.2 == 0.3: %0d", vals[2] == 0.3);
    $display("from C bits: next after 1.0 %0d, 0.1 %0d",
             rd_from_bits(64'h3ff0000000000001) == vals[3],
             rd_from_bits(64'h3fb999999999999a) == 0.1);
    $display("realtime: %h same in C %0d", $realtobits(rt), rd_bits(rt) == $realtobits(0.1));
    $display("type(realtime) == type(real): %0d", type(rt) == type(r));
  end
endmodule
