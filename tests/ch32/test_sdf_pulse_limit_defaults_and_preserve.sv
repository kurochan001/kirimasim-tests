/*
:name: test_sdf_pulse_limit_defaults_and_preserve
:description: An SDF delay without pulse limits sets both limits to 100% of the delay, empty parentheses for the limits keep their current values, and INCREMENT annotations that make a limit negative set it to 0 (IEEE 1800-2023 Section 32.7)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.7 32.5 30.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_pulse_limit_defaults_and_preserve.expected
*/
// IEEE 1800-2023 §32.7: an SDF delay annotated without pulse limits gets
// limits computed from the reject and error percentages, 100% unless an
// invocation option changes them, so both limits equal the delay; a delay
// whose limits are left empty, ((d) () ()), keeps the current limits (§32.5),
// which for a path whose specify delay was 0 are 0; and an INCREMENT that
// takes a limit below 0 sets it to 0. §30.7: a pulse narrower than the reject
// limit is rejected, one narrower than the error limit becomes x (from the
// scheduled time of its leading edge to that of its trailing edge), and a
// wider one passes.
//
// The input p carries pulses of width 1 to 6, 20 time units apart.
//   qd: specify delay 0, SDF (IOPATH a y (6)): delay 6 and limits 6 and 6, so
//       widths 1 to 5 are rejected and 6 passes.
//   qz: specify delay 0, SDF (IOPATH a y ((6) () ())): delay 6 and limits 0,
//       so every pulse passes.
//   qe: specify delay 6, SDF (PATHPULSE a y (2) (4)) and then
//       (IOPATH a y ((8) () ())): delay 8 and limits still 2 and 4, so 1 is
//       rejected, 2 and 3 are x and 4 to 6 pass, 8 after p.
//   qi: specify delay 6, SDF (PATHPULSE a y (3) (3)), then INCREMENT by
//       (() (-4) (-5)), which gives -1 and -2 and so 0 and 0, then INCREMENT
//       by (() (2) (3)): limits 2 and 3, so 1 is rejected, 2 is x and 3 to 6
//       pass (without the adjustment to 0 the limits would end at 1 and 1,
//       and 1 and 2 would pass). The empty delay keeps the delay 6.
// The changes of each output from time 20 on are recorded and printed at the
// end. The test creates its SDF file in the current directory.
//
// Icarus Verilog 13.0 ignores the pulse limits of the SDF file.

`timescale 1ns/1ns

module sdf_pl_zero_cell (input a, output y);
  buf (y, a);
  specify
    (a => y) = 0;
  endspecify
endmodule

module sdf_pl_six_cell (input a, output y);
  buf (y, a);
  specify
    (a => y) = 6;
  endspecify
endmodule

module test_sdf_pulse_limit_defaults_and_preserve;
  reg p = 0;
  wire yd, yz, ye, yi;
  string ld = "", lz = "", le = "", li = "";
  integer f;

  sdf_pl_zero_cell qd (p, yd);
  sdf_pl_zero_cell qz (p, yz);
  sdf_pl_six_cell qe (p, ye);
  sdf_pl_six_cell qi (p, yi);

  always @(yd) if ($time >= 20) ld = {ld, $sformatf(" %0d:%b", $time, yd)};
  always @(yz) if ($time >= 20) lz = {lz, $sformatf(" %0d:%b", $time, yz)};
  always @(ye) if ($time >= 20) le = {le, $sformatf(" %0d:%b", $time, ye)};
  always @(yi) if ($time >= 20) li = {li, $sformatf(" %0d:%b", $time, yi)};

  initial begin
    f = $fopen("test_sdf_pulse_limit_defaults_and_preserve.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_pl_zero_cell\") (INSTANCE qd)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (IOPATH a y (6)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_pl_zero_cell\") (INSTANCE qz)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (IOPATH a y ((6) () ())))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_pl_six_cell\") (INSTANCE qe)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (PATHPULSE a y (2) (4)) (IOPATH a y ((8) () ())))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_pl_six_cell\") (INSTANCE qi)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (PATHPULSE a y (3) (3)))");
    $fdisplay(f, "      (INCREMENT (IOPATH a y (() (-4) (-5))))");
    $fdisplay(f, "      (INCREMENT (IOPATH a y (() (2) (3)))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_pulse_limit_defaults_and_preserve.sdf");
    #20 p = 1;
    #1 p = 0;     // 20 to 21: width 1
    #19 p = 1;
    #2 p = 0;     // 40 to 42: width 2
    #18 p = 1;
    #3 p = 0;     // 60 to 63: width 3
    #17 p = 1;
    #4 p = 0;     // 80 to 84: width 4
    #16 p = 1;
    #5 p = 0;     // 100 to 105: width 5
    #15 p = 1;
    #6 p = 0;     // 120 to 126: width 6
    #24 $display("qd y:%s", ld);
    $display("qz y:%s", lz);
    $display("qe y:%s", le);
    $display("qi y:%s", li);
  end
endmodule
