/*
:name: test_illegal_timeformat_unit_below_range
:description: the units_number argument of $timeformat is the constant -16, below the range -15 through 2 (IEEE 1800-2023 Section 20.4.3)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the third $timeformat call gives -16 as its units_number, below the allowed -15
:expected_stderr_regex: test_illegal_timeformat_unit_below_range\.sv:30:
*/
// IEEE 1800-2023 §20.4.3: the units_number argument of $timeformat shall be
// an integer from -15 (1 fs) through 2 (100 s), one of the units of Table
// 20-2. The first two calls use the ends of that range, -15 and 2, and are
// legal; their precision_number 0 is in the range as well. The third call
// gives the constant -16, one below the smallest, which is the one error;
// the arguments are constants, so a tool can reject the call before the
// simulation starts. Without the third call the design is legal.
// Icarus Verilog 13.0 and the 5.054 release of Verilator accept the call,
// so the cited clause alone decides this test.

`timescale 1ns/1ns

module test_illegal_timeformat_unit_below_range;
  initial begin
    $timeformat(-15, 0, " fs", 12);
    $timeformat(2, 0, " hs", 12);
    $timeformat(-16, 0, " x", 12);   // illegal: unit below -15 to 2
  end
endmodule
