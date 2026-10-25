/*
:name: test_time_literal_units_and_fraction
:description: A time literal has an integer or fixed-point numeric part and one of the units fs, ps, ns, us, ms or s, and each is converted to the current time unit (IEEE 1800-2023 Section 5.8)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_time_literal_units_and_fraction.expected
*/
// IEEE 1800-2023 §5.8 B002: a time literal is a numeric part, which is an
// integer or a fixed-point number, followed by one of the units fs, ps, ns, us,
// ms or s. The test uses all six units and one fixed-point value. With a time
// unit and precision of 1 fs, $time reports the accumulated time in
// femtoseconds, so each line shows the sum of the delays before it.

`timescale 1fs/1fs

module test_time_literal_units_and_fraction;
  initial begin
    #1fs;   $display("t1=%0d", $time);
    #2ps;   $display("t2=%0d", $time);
    #3.5ns; $display("t3=%0d", $time);
    #4us;   $display("t4=%0d", $time);
    #5ms;   $display("t5=%0d", $time);
    #6s;    $display("t6=%0d", $time);
  end
endmodule
