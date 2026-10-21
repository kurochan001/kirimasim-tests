/*
:name: test_sdf_cond_unknown_true
:description: A COND entry of an SDF file annotates its path when the condition is x or z, which counts as true (IEEE 1800-2023 Sections 32.4.1 and 30.4.4.1)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.1 30.4.4.1 30.4.4.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_cond_unknown_true.expected
*/
// IEEE 1800-2023 §32.4.1: (COND s (IOPATH a y ...)) annotates the module path
// from a to y whose condition is s. §30.4.4.1: a condition of x or z is true,
// so with s = x the path is annotated and gets the delay 6; the ifnone path,
// whose delay is 8, is not used (§30.4.4.3). The output therefore changes at
// 16 after a rises at 10, so it is still 0 at 15 and is 1 at 17. Icarus
// Verilog 13.0 treats the condition as false and uses the ifnone path; the
// 5.052 release ignores $sdf_annotate and module path delays.

`timescale 1ns/1ns

module sdf_x_cell(output y, input a, input s);
  buf (y, a);
  specify
    if (s) (a => y) = 1;
    ifnone (a => y) = 8;
  endspecify
endmodule

module test_sdf_cond_unknown_true;
  reg a = 0;
  reg s = 1'bx;
  wire y;
  integer f;

  sdf_x_cell u(y, a, s);

  initial begin
    f = $fopen("test_sdf_cond_unknown_true.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_x_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (COND s (IOPATH a y (6)))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_cond_unknown_true.sdf");
    #10 a = 1;
    #5 $display("%0d: y=%b", $time, y);
    #2 $display("%0d: y=%b", $time, y);
    #5 $finish;
  end
endmodule
