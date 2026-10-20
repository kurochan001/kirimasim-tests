/*
:name: test_sdf_pulse_limits
:description: A delay annotated from SDF also sets the pulse limits of the path, by default to 100% of the delay, so narrower pulses are rejected; PATHPULSE limits larger than the delay act as if they were equal to it (IEEE 1800-2023 Section 32.7)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.7 32.4.1 30.7.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_pulse_limits.expected
*/
// IEEE 1800-2023 §32.7: when SDF annotates the delay of a path, its pulse
// limits are set from the reject and error percentages, which are 100% unless
// an invocation option changes them, so both limits equal the delay and a
// pulse narrower than the delay is rejected (30.7.1). PATHPULSE limits larger
// than the delay act like limits equal to the delay. The specify delays are
// 0. The path to y gets the delay 6: a pulse of 3 on a is rejected and one of
// 8 passes. The path to z gets the delay 4 and PATHPULSE limits of 10, which
// count as 4, so a pulse of 5 on b passes. The test creates its SDF file in
// the current directory.

`timescale 1ns/1ns

module sdf_pulse_cell(output y, output z, input a, input b);
  buf (y, a);
  buf (z, b);
  specify
    (a => y) = 0;
    (b => z) = 0;
  endspecify
endmodule

module test_sdf_pulse_limits;
  reg a = 0, b = 0;
  wire y, z;
  integer f;

  sdf_pulse_cell u(y, z, a, b);

  initial begin
    f = $fopen("test_sdf_pulse_limits.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_pulse_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY");
    $fdisplay(f, "      (ABSOLUTE (IOPATH a y (6)) (IOPATH b z (4)))");
    $fdisplay(f, "      (PATHPULSE b z (10) (10)))))");
    $fclose(f);
    $sdf_annotate("test_sdf_pulse_limits.sdf");
    #10 a = 1;
    #3 a = 0;
    #17 a = 1;
    #8 a = 0;
    #12 b = 1;
    #5 b = 0;
    #20 $finish;
  end

  always @(y or z) if ($time >= 10) $display("%0d: y=%b z=%b", $time, y, z);
endmodule
