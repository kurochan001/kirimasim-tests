/*
:name: test_sdf_iopath_retain_forms
:description: IOPATH, COND IOPATH and CONDELSE IOPATH entries with a RETAIN value annotate the delays and pulse limits of the same module paths as without it: IOPATH both the unconditional and the conditional paths between its ports, COND only the path with the same condition, CONDELSE only the ifnone path (IEEE 1800-2023 Section 32.4.1)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.1 32.5 30.7 30.4.4.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_iopath_retain_forms.expected
*/
// IEEE 1800-2023 §32.4.1, Table 32-1: an IOPATH entry with a RETAIN value
// annotates the delays and pulse limits of the conditional and unconditional
// module paths between its ports; with COND it annotates only the paths with
// the same condition, and with CONDELSE only the ifnone path (§30.4.4.3: used
// when no condition of the other paths to that output is true). The RETAIN
// value itself may be ignored. §32.5: the value ((10) (4) (8)) is the delay
// 10 with the reject limit 4 and the error limit 8. §30.7: a pulse narrower
// than the reject limit is rejected, one narrower than the error limit
// becomes x from the scheduled time of its leading edge to that of its
// trailing edge, and a wider one passes; without annotation both limits are
// the delay.
//
// Every path of the cell has the delay 20. Each instance gets the entries
//   (IOPATH a y (RETAIN (10)) ((10) (4) (8)))        unconditional path
//   (IOPATH a v (RETAIN (10)) ((10) (4) (8)))        if (s) and if (!s) paths
//   (COND s (IOPATH a z (RETAIN (10)) ((10) (4) (8))))   if (s) and if (!s)
//   (CONDELSE (IOPATH a w (RETAIN (10)) ((10) (4) (8))))  if (s) and ifnone
// so y and v are annotated in both instances, z only in u1 (s = 1), where
// its if (s) path is used, and w only in u0 (s = 0), where its ifnone path is
// used. The RETAIN value equals the delay, so a tool that uses it has no
// time in which an output could keep its old value or go to x before the
// delay ends; the outputs are sampled only at times away from their changes.
//
// The input a has pulses of width 2 (20 to 22), 6 (50 to 56) and 9 (80 to
// 89), then rises at 120 and falls at 160. An annotated output rejects the
// first pulse (0 at 31), is x for the second (63), passes the third (1 at
// 95), and follows the step 10 later (0 at 125, 1 at 135, 0 at 175). An
// output that is not annotated rejects all pulses and follows the step 20
// later (0 at 135, 1 at 145 and 175, 0 at 185). The test creates its SDF file
// in the current directory.

`timescale 1ns/1ns

module sdf_rt_cell (input a, s, output y, v, z, w);
  buf (y, a);
  buf (v, a);
  buf (z, a);
  buf (w, a);
  specify
    (a => y) = 20;
    if (s) (a => v) = 20;
    if (!s) (a => v) = 20;
    if (s) (a => z) = 20;
    if (!s) (a => z) = 20;
    if (s) (a => w) = 20;
    ifnone (a => w) = 20;
  endspecify
endmodule

module test_sdf_iopath_retain_forms;
  reg a = 0, one = 1, zero = 0;
  wire y1, v1, z1, w1, y0, v0, z0, w0;
  integer f, i;

  sdf_rt_cell u1 (a, one, y1, v1, z1, w1);
  sdf_rt_cell u0 (a, zero, y0, v0, z0, w0);

  initial begin
    f = $fopen("test_sdf_iopath_retain_forms.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    for (i = 1; i >= 0; i = i - 1) begin
      $fdisplay(f, "  (CELL (CELLTYPE \"sdf_rt_cell\") (INSTANCE u%0d)", i);
      $fdisplay(f, "    (DELAY (ABSOLUTE");
      $fdisplay(f, "      (IOPATH a y (RETAIN (10)) ((10) (4) (8)))");
      $fdisplay(f, "      (IOPATH a v (RETAIN (10)) ((10) (4) (8)))");
      $fdisplay(f, "      (COND s (IOPATH a z (RETAIN (10)) ((10) (4) (8))))");
      $fdisplay(f, "      (CONDELSE (IOPATH a w (RETAIN (10)) ((10) (4) (8)))))))");
    end
    $fdisplay(f, ")");
    $fclose(f);
    $sdf_annotate("test_sdf_iopath_retain_forms.sdf");
  end

  initial begin
    #20 a = 1;
    #2 a = 0;       // 20 to 22: width 2
    #28 a = 1;
    #6 a = 0;       // 50 to 56: width 6
    #24 a = 1;
    #9 a = 0;       // 80 to 89: width 9
    #31 a = 1;      // 120
    #40 a = 0;      // 160
  end

  task show;
    $display("%0d: u1 y=%b v=%b z=%b w=%b, u0 y=%b v=%b z=%b w=%b", $time, y1, v1, z1, w1,
             y0, v0, z0, w0);
  endtask

  initial begin
    #31 show;
    #32 show;       // 63
    #32 show;       // 95
    #30 show;       // 125
    #10 show;       // 135
    #10 show;       // 145
    #30 show;       // 175
    #10 show;       // 185
  end
endmodule
