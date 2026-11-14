/*
:name: test_timeformat_every_unit_and_precision
:description: The units number of $timeformat selects each time unit of Table 20-2, from 2 (100 s) to -15 (1 fs), in which %t prints a time, and the precision number gives the number of digits after the decimal point, 0 to 5 here, including the 5 of the example of the standard (IEEE 1800-2023 Section 20.4.3)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.4.3
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeformat_every_unit_and_precision.expected
*/
// IEEE 1800-2023 §20.4.3: $timeformat(units, precision, suffix, width) sets
// how %t prints a time: units is one of the exponents of Table 20-2 (20.4.1),
// from 2 for 100 s down to -15 for 1 fs, and the time is printed as a number
// of those units; precision is the number of digits after the decimal point;
// the suffix follows the number, and a minimum width of 0 adds no padding.
// The example of the clause, $timeformat(-9, 5, " ns", 10), prints 10 ns as
// 10.00000 ns, which is 11 characters, wider than 10, so it is not padded.
//
// The module has the time unit and precision 1 fs, so a value given to %t is
// a number of femtoseconds (21.2.1.1). After the example at 10 ns, the test
// prints one value in each of the 18 units, with precisions from 0 to 5. The
// clauses do not say whether a digit after the precision rounds or is cut
// off, so each value has either no more digits than the precision or one
// more digit, a 3, after them, for which both give the same number: 234.53
// units of 10 s with precision 1 print 234.5 either way.

`timescale 1fs/1fs

module test_timeformat_every_unit_and_precision;
  initial begin
    #(64'd10_000_000);
    $timeformat(-9, 5, " ns", 10);
    $display("example: [%t]", $time);
    $timeformat(2, 5, " (100 s)", 0);
    $display("units 2, precision 5: [%t]", 64'd1_234_567_300_000_000_000);
    $timeformat(1, 1, " (10 s)", 0);
    $display("units 1, precision 1: [%t]", 64'd2_345_300_000_000_000_000);
    $timeformat(0, 2, " (s)", 0);
    $display("units 0, precision 2: [%t]", 64'd3_456_783_000_000_000_000);
    $timeformat(-1, 3, " (100 ms)", 0);
    $display("units -1, precision 3: [%t]", 64'd4_567_898_730_000_000_000);
    $timeformat(-2, 4, " (10 ms)", 0);
    $display("units -2, precision 4: [%t]", 64'd567_898_300_000_000);
    $timeformat(-3, 5, " (ms)", 0);
    $display("units -3, precision 5: [%t]", 64'd678_987_653_000_000);
    $timeformat(-4, 5, " (100 us)", 0);
    $display("units -4, precision 5: [%t]", 64'd789_876_543_300_000);
    $timeformat(-5, 0, " (10 us)", 0);
    $display("units -5, precision 0: [%t]", 64'd898_763_000_000_000);
    $timeformat(-6, 1, " (us)", 0);
    $display("units -6, precision 1: [%t]", 64'd98_730_000_000);
    $timeformat(-7, 2, " (100 ns)", 0);
    $display("units -7, precision 2: [%t]", 64'd87_654_300_000);
    $timeformat(-8, 3, " (10 ns)", 0);
    $display("units -8, precision 3: [%t]", 64'd76_543_213_000);
    $timeformat(-9, 4, " (ns)", 0);
    $display("units -9, precision 4: [%t]", 64'd65_432_123_430);
    $timeformat(-10, 5, " (100 ps)", 0);
    $display("units -10, precision 5: [%t]", 64'd5_432_123);
    $timeformat(-11, 4, " (10 ps)", 0);
    $display("units -11, precision 4: [%t]", 64'd4_321_234);
    $timeformat(-12, 3, " (ps)", 0);
    $display("units -12, precision 3: [%t]", 64'd3_212_345);
    $timeformat(-13, 2, " (100 fs)", 0);
    $display("units -13, precision 2: [%t]", 64'd2_123_456);
    $timeformat(-14, 1, " (10 fs)", 0);
    $display("units -14, precision 1: [%t]", 64'd123);
    $timeformat(-15, 0, " (fs)", 0);
    $display("units -15, precision 0: [%t]", 64'd234);
  end
endmodule
