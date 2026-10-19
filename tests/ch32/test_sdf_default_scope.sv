/*
:name: test_sdf_default_scope
:description: Without a module_instance argument, $sdf_annotate annotates relative to the module instance that calls it (IEEE 1800-2023 Section 32.9)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_default_scope.expected
*/
// IEEE 1800-2023 §32.9: when the module_instance argument is left out, the
// annotation uses the module that contains the $sdf_annotate call. Two
// instances of a wrapper hold the same cell instance c; only the one whose
// parameter is set calls $sdf_annotate, so only its c gets the delay 4. The
// call is made at time 1, after the file has been written at time 0.

`timescale 1ns/1ns

module sdf_dscope_cell(output y, input a);
  buf (y, a);
  specify
    (a => y) = 1;
  endspecify
endmodule

module sdf_dscope_wrap #(parameter bit ANNOTATE = 0) (output y, input a);
  sdf_dscope_cell c(y, a);
  initial if (ANNOTATE) #1 $sdf_annotate("test_sdf_default_scope.sdf");
endmodule

module test_sdf_default_scope;
  reg a = 0;
  wire y1, y2;
  integer f;

  sdf_dscope_wrap #(.ANNOTATE(0)) p1(y1, a);
  sdf_dscope_wrap #(.ANNOTATE(1)) p2(y2, a);

  initial begin
    f = $fopen("test_sdf_default_scope.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_dscope_cell\") (INSTANCE c)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH a y (4))))))");
    $fclose(f);
    #10 a = 1;
    #10 $finish;
  end

  always @(y1 or y2) if ($time >= 10) $display("%0d: y1=%b y2=%b", $time, y1, y2);
endmodule
