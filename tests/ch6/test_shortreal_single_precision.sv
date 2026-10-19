/*
:name: test_shortreal_single_precision
:description: A shortreal holds a single-precision value, also when written by a nonblocking assignment, as an array element or by a cast (IEEE 1800-2023 Section 6.12)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12 6.24.1 20.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shortreal_single_precision.expected
*/
// IEEE 1800-2023 §6.12: shortreal is the C float type, so storing 0.1 in it
// keeps the nearest single-precision value, 0.100000001490116..., and reading
// it back into a real gives that value, not the double nearest to 0.1. This
// holds however the shortreal is written: by a blocking or a nonblocking
// assignment, as an element of an array, and for a cast to shortreal
// (6.24.1). $shortrealtobits (20.5) gives its bits, 32'h3dcccccd.

module test_shortreal_single_precision;
  shortreal s, t;
  shortreal arr[2];
  real r;

  initial begin
    s = 0.1;
    r = s;
    $display("blocking: %.10f", r);
    t <= 0.1;
    #1 r = t;
    $display("nonblocking: %.10f", r);
    arr[1] = 0.1;
    r = arr[1];
    $display("array element: %.10f", r);
    r = shortreal'(0.1);
    $display("cast: %.10f", r);
    $display("equal to the real 0.1: %0d", s == 0.1);
    $display("bits: %h", $shortrealtobits(s));
  end
endmodule
