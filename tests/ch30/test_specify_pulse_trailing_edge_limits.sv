/*
:name: test_specify_pulse_trailing_edge_limits
:description: Whether a pulse on a path output is rejected, filtered to x or passed is decided by the pulse limits of the delay of its trailing edge, not of its leading edge (IEEE 1800-2023 Section 30.7)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.7 32.5 32.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_pulse_trailing_edge_limits.expected
*/
// IEEE 1800-2023 §30.7: each transition delay of a path has its own reject and
// error limits, by default both equal to that delay, and the limits of the
// delay that forms the trailing edge of a pulse decide how the pulse is
// filtered. §30.7.3 and §32.5: SDF can annotate the limits of each transition
// delay; in an IOPATH entry ((d) (r) (e)) is the delay d with the reject limit
// r and the error limit e, and with two such values the first is for 0->1
// and the second for 1->0 (§32.8).
//
// Cell td has (a => y) = (4, 8) and default limits. A pulse on a from 10 to 12
// schedules y to rise at 14 and to fall at 20: the output pulse is 6 wide,
// and its trailing edge is a fall, whose limits are 8, so it is rejected
// (the limits of the rise, 4, would let it pass).
//
// Cell ts gets from the SDF file the rise delay 4 with the limits 1 and 2 and
// the fall delay 8 with the limits 8 and 8. The same positive pulse is
// rejected by the limits of the fall. After a rises again at 30 (y rises at
// 34), a negative pulse on a from 50 to 56 schedules y to fall at 58 and to
// rise at 60: this pulse of 2 has a rising trailing edge, whose error limit
// 2 lets it pass, so y falls at 58 and rises at 60 (the limits of the fall,
// or the larger limits of the two delays, would reject it). In td the same
// negative pulse is narrower than the rise limit 4 and is rejected.
// The changes of each output from time 10 on are printed at the end. The test
// creates its SDF file in the current directory.

`timescale 1ns/1ns

module te_default_cell (input a, output y);
  buf (y, a);
  specify
    (a => y) = (4, 8);
  endspecify
endmodule

module te_sdf_cell (input a, output y);
  buf (y, a);
  specify
    (a => y) = 1;
  endspecify
endmodule

module test_specify_pulse_trailing_edge_limits;
  reg a = 0;
  wire yd, ys;
  string ld = "", ls = "";
  integer f;

  te_default_cell td (a, yd);
  te_sdf_cell ts (a, ys);

  always @(yd) if ($time >= 10) ld = {ld, $sformatf(" %0d:%b", $time, yd)};
  always @(ys) if ($time >= 10) ls = {ls, $sformatf(" %0d:%b", $time, ys)};

  initial begin
    f = $fopen("test_specify_pulse_trailing_edge_limits.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"te_sdf_cell\") (INSTANCE ts)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH a y ((4) (1) (2)) ((8) (8) (8)))))))");
    $fclose(f);
    $sdf_annotate("test_specify_pulse_trailing_edge_limits.sdf");
    #10 a = 1;
    #2 a = 0;      // 10 to 12: output pulse from 14 to 20, trailing fall
    #18 a = 1;     // 30: y rises at 34
    #20 a = 0;
    #6 a = 1;      // 50 to 56: output pulse from 58 to 60, trailing rise
    #24 $display("td y:%s", ld);
    $display("ts y:%s", ls);
  end
endmodule
