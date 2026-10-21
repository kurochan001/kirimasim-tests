/*
:name: test_sdf_timescale
:description: The TIMESCALE of an SDF file gives the unit of its delay values, so a delay is converted from that unit to the time unit of the design (IEEE 1800-2023 Sections 32.3 and 32.4.1)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.3 32.4.1 3.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_timescale.expected
*/
// IEEE 1800-2023 §32.3: the DELAYFILE TIMESCALE gives the time unit of the
// delay values in the file. §32.4.1: an IOPATH entry replaces the delay of the
// module path. The design has a time unit of 1 ns and a precision of 1 ps; the
// file's TIMESCALE is 100 ps, so its value 5 is 500 ps. The path from a to y
// therefore changes y at 10.5 after a rises at 10, and not at 10.2. Icarus
// Verilog 13.0 takes the value in the time unit of the design, 5 ns; Verilator
// 5.052 ignores $sdf_annotate and module path delays.

`timescale 1ns/1ps

module sdf_ts_cell(output y, input a);
  buf (y, a);
  specify
    (a => y) = 1;
  endspecify
endmodule

module test_sdf_timescale;
  reg a = 0;
  wire y;
  integer f;

  sdf_ts_cell u(y, a);

  initial begin
    f = $fopen("test_sdf_timescale.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 100ps)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_ts_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (IOPATH a y (5))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_timescale.sdf");
    #10 a = 1;
    #0.2 $display("%0.3f: y=%b", $realtime, y);
    #0.4 $display("%0.3f: y=%b", $realtime, y);
    #1 $finish;
  end
endmodule
