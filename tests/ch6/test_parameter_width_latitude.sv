/*
:name: test_parameter_width_latitude
:description: an untyped parameter with an unsized value has a zero right bound and a left bound of at least 31, while its exact width is left to the tool
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_width_latitude.expected
*/
// IEEE 1800-2023 6.20.2: for a parameter declared with no range and no data
// type whose final value is an unsized literal, the high index of the implied
// range is implementation dependent but at least 31 and the low index is 0.
// The test prints the value, the right bound, and whether the left bound is at
// least 31, so it accepts any conforming width (32, 64, ...) and fails a tool
// that chooses a narrower or a negative-based range. It deliberately does not
// print the exact width, which the clause leaves open.

module test_parameter_width_latitude #(parameter P = 1);
  initial
    $display("p=%0d right=%0d ge31=%0d", P, $right(P), ($left(P) >= 31));
endmodule
