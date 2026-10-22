/*
:name: test_sdf_pulse_limit_near_delay_boundary
:description: Default SDF pulse limits reject a pulse just below the annotated delay and pass one just above it (IEEE 1800-2023 Section 32.7)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.7 30.7.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_pulse_limit_near_delay_boundary.expected
*/
// IEEE 1800-2023 32.7 30.7.1: With an annotated delay of four and no percentage
// override, widths three and five distinguish rejection from transmission at
// the default limit.
// Oracle checks: The 5.052 release does not reproduce the clause-derived
// output.

`timescale 1ns/1ns
module boundary_pulse_leaf(input a, output y);
  buf(y, a);
  specify (a => y) = 0; endspecify
endmodule
module test_sdf_pulse_limit_near_delay_boundary;
  reg a = 0;
  wire y;
  integer fd;
  boundary_pulse_leaf u(a, y);
  initial begin
    fd = $fopen("pulse.sdf", "w");
    if (fd == 0) $fatal(1, "open failed");
    $fdisplay(fd, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(fd, "(CELL (CELLTYPE \"boundary_pulse_leaf\") (INSTANCE u)");
    $fdisplay(fd, "(DELAY (ABSOLUTE (IOPATH a y (4))))))");
    $fclose(fd); $sdf_annotate("pulse.sdf");
    #10 a = 1; #3 a = 0;
    #5 $display("short_rejected=%b", y);
    #2 a = 1; #5 a = 0;
    #1 $display("long_high=%b", y);
    #4 $display("long_low=%b", y);
  end
endmodule
