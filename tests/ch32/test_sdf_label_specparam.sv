/*
:name: test_sdf_label_specparam
:description: An SDF LABEL entry sets specparams, and the procedural delay and the module path delay that use them take the new values (IEEE 1800-2023 Section 32.4.3)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.3 6.20.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_label_specparam.expected
*/
// IEEE 1800-2023 §32.4.3: the LABEL section of an SDF file annotates
// specparams, and every expression that uses an annotated specparam is
// evaluated again. The specparam dq is used in a procedural delay and dy as a
// module path delay. The file sets dq to 7 and dy to 4: q, set to 1 at 20, goes
// back to 0 after 7, and y follows a after 4. Icarus Verilog 13.0 does not read
// the LABEL section. Verilator 5.052 ignores $sdf_annotate and module path
// delays.

`timescale 1ns/1ns

module sdf_label_cell(output reg q, output y, input a);
  specparam dq = 2, dy = 1;
  buf (y, a);
  specify
    (a => y) = dy;
  endspecify
  initial begin
    q = 0;
    #20 q = 1;
    #dq q = 0;
  end
endmodule

module test_sdf_label_specparam;
  reg a = 0;
  wire q, y;
  integer f;

  sdf_label_cell u(q, y, a);

  initial begin
    f = $fopen("test_sdf_label_specparam.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_label_cell\") (INSTANCE u)");
    $fdisplay(f, "    (LABEL (ABSOLUTE");
    $fdisplay(f, "      (dq 7)");
    $fdisplay(f, "      (dy 4)))))");
    $fclose(f);
    $sdf_annotate("test_sdf_label_specparam.sdf");
    #10 a = 1;
    #30 $finish;
  end

  always @(q or y) if ($time >= 10) $display("%0d: q=%b y=%b", $time, q, y);
endmodule
