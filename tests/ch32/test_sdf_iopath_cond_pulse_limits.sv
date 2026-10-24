/*
:name: test_sdf_iopath_cond_pulse_limits
:description: An IOPATH entry annotates the delay and the pulse limits of every module path between its ports, conditional or not, while a COND IOPATH entry annotates them only on the conditional path with the same condition (IEEE 1800-2023 Section 32.4.1)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.1 32.5 30.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_iopath_cond_pulse_limits.expected
*/
// IEEE 1800-2023 §32.4.1, Table 32-1: (IOPATH ...) annotates the delays and
// pulse limits of the conditional and the unconditional module paths between
// its two ports; (COND c (IOPATH ...)) annotates only the conditional paths
// between them whose condition is c. §32.5: the value ((6) (2) (4)) is the
// delay 6 with the reject limit 2 and the error limit 4. §30.7: a pulse
// narrower than the reject limit is rejected, one narrower than the error
// limit becomes x (from the scheduled time of its leading edge to that of its
// trailing edge), and a wider one passes; by default both limits equal the
// delay.
//
// The cell has the conditional paths if (s) (a => y) and if (!s) (a => y) and
// the unconditional path (a => z), all with the delay 10. The instances i1
// (s = 1) and i0 (s = 0) get (IOPATH a y ((6) (2) (4))) and the same for a z;
// c1 (s = 1) and c0 (s = 0) get only (COND s (IOPATH a y ((6) (2) (4)))).
// The input p carries pulses of width 1 to 6, 20 time units apart, and then
// rises at 140 and falls at 170. An annotated path rejects width 1, turns 2
// and 3 into x, passes 4 to 6, and follows the step 6 later. A path that is
// not annotated has the delay 10 and the limits 10, so it rejects all the
// pulses and follows the step 10 later: the path for !s in c0 and the
// unconditional path in c1 and c0.
// The changes of each output from time 20 on are recorded and printed at the
// end. The test creates its SDF file in the current directory.
//
// Icarus Verilog 13.0 ignores the pulse limits of the SDF values and leaves
// paths with COND entries at their specify delays.

`timescale 1ns/1ns

module sdf_cl_cell (input a, s, output y, z);
  buf (y, a);
  buf (z, a);
  specify
    if (s) (a => y) = 10;
    if (!s) (a => y) = 10;
    (a => z) = 10;
  endspecify
endmodule

module test_sdf_iopath_cond_pulse_limits;
  reg p = 0, one = 1, zero = 0;
  wire i1y, i1z, i0y, i0z, c1y, c1z, c0y, c0z;
  string l0 = "", l1 = "", l2 = "", l3 = "", l4 = "", l5 = "", l6 = "", l7 = "";
  integer f;

  sdf_cl_cell i1 (p, one, i1y, i1z);
  sdf_cl_cell i0 (p, zero, i0y, i0z);
  sdf_cl_cell c1 (p, one, c1y, c1z);
  sdf_cl_cell c0 (p, zero, c0y, c0z);

  always @(i1y) if ($time >= 20) l0 = {l0, $sformatf(" %0d:%b", $time, i1y)};
  always @(i1z) if ($time >= 20) l1 = {l1, $sformatf(" %0d:%b", $time, i1z)};
  always @(i0y) if ($time >= 20) l2 = {l2, $sformatf(" %0d:%b", $time, i0y)};
  always @(i0z) if ($time >= 20) l3 = {l3, $sformatf(" %0d:%b", $time, i0z)};
  always @(c1y) if ($time >= 20) l4 = {l4, $sformatf(" %0d:%b", $time, c1y)};
  always @(c1z) if ($time >= 20) l5 = {l5, $sformatf(" %0d:%b", $time, c1z)};
  always @(c0y) if ($time >= 20) l6 = {l6, $sformatf(" %0d:%b", $time, c0y)};
  always @(c0z) if ($time >= 20) l7 = {l7, $sformatf(" %0d:%b", $time, c0z)};

  initial begin
    f = $fopen("test_sdf_iopath_cond_pulse_limits.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_cl_cell\") (INSTANCE i1)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (IOPATH a y ((6) (2) (4))) (IOPATH a z ((6) (2) (4))))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_cl_cell\") (INSTANCE i0)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (IOPATH a y ((6) (2) (4))) (IOPATH a z ((6) (2) (4))))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_cl_cell\") (INSTANCE c1)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (COND s (IOPATH a y ((6) (2) (4)))))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_cl_cell\") (INSTANCE c0)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (COND s (IOPATH a y ((6) (2) (4))))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_iopath_cond_pulse_limits.sdf");
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
    #14 p = 1;    // 140: step
    #30 p = 0;    // 170
    #20 $display("i1 y:%s", l0);
    $display("i1 z:%s", l1);
    $display("i0 y:%s", l2);
    $display("i0 z:%s", l3);
    $display("c1 y:%s", l4);
    $display("c1 z:%s", l5);
    $display("c0 y:%s", l6);
    $display("c0 z:%s", l7);
  end
endmodule
