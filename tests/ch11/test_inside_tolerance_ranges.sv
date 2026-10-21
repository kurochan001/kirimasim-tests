/*
:name: test_inside_tolerance_ranges
:description: Ranges written with +/- and +%- in inside give absolute and relative tolerances, truncated to integers for an integral center and swapped when needed (IEEE 1800-2023 Section 11.4.13)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inside_tolerance_ranges.expected
*/
// IEEE 1800-2023 §11.4.13: [A +/- B] is the range from A - B to A + B, and [A
// +%- B] the range A plus or minus B percent of A, with the bounds swapped when
// the first is larger. The range has the type of A: for an integral A the
// tolerance is truncated, so 25 percent of 7, 1.75, becomes 1 and the range is
// [6:8], or [-8:-6] for -7, while for the real 7.0 it is [5.25:8.75].
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports this construct of
// IEEE 1800-2023.

module test_inside_tolerance_ranges;
  int x = 9, a, y;
  real ra = 7.0, yr;
  initial begin
    $display("9 in [10 +/- 2]: %b", x inside {[10 +/- 2]});
    $display("9 in [10 +/- -2]: %b", x inside {[10 +/- -2]});
    $display("9 in [20 +%%- 25]: %b", x inside {[20 +%- 25]});
    a = 7;
    y = 6;
    $display("6 in [7 +%%- 25]: %b", y inside {[a +%- 25]});
    y = 5;
    $display("5 in [7 +%%- 25]: %b", y inside {[a +%- 25]});
    a = -7;
    y = -8;
    $display("-8 in [-7 +%%- 25]: %b", y inside {[a +%- 25]});
    y = -9;
    $display("-9 in [-7 +%%- 25]: %b", y inside {[a +%- 25]});
    yr = 5.3;
    $display("5.3 in [7.0 +%%- 25]: %b", yr inside {[ra +%- 25]});
    yr = 5.2;
    $display("5.2 in [7.0 +%%- 25]: %b", yr inside {[ra +%- 25]});
  end
endmodule
