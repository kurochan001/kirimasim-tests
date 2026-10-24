/*
:name: test_sdf_instance_array_index
:description: The module_instance argument of $sdf_annotate can select one element of an array of instances, and without it the annotation scope is the module instance that calls $sdf_annotate (IEEE 1800-2023 Section 32.9)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.9 32.6 23.3.3.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_instance_array_index.expected
*/
// IEEE 1800-2023 §32.9: the optional module_instance argument gives the
// scope of the annotation, and array indices are permitted in it; when it is
// left out, the scope is the module that contains the call of $sdf_annotate.
// wa [1:0] is an array of two wrappers (23.3.3.5), whose outputs drive
// ya[1] and ya[0]; the first file gives the cell c the delay 3 and is
// annotated with the scope wa[1], so wa[0] keeps its specify delay 1. The
// wrapper ws, whose parameter SELF is 1, calls $sdf_annotate at 1 for the
// second file, which gives c the delay 5, without a module_instance, so only
// its own cell gets it. When a rises at 10, ya[0] follows at 11, ya[1] at 13
// and ys at 15. Icarus Verilog 13.0 fails an internal assertion when it
// compiles the element wa[1] as an argument, and Verilator 5.052 ignores
// $sdf_annotate and module path delays.

`timescale 1ns/1ns

module sdf_aidx_cell(output y, input a);
  buf (y, a);
  specify
    (a => y) = 1;
  endspecify
endmodule

module sdf_aidx_wrap #(parameter bit SELF = 0) (output y, input a);
  sdf_aidx_cell c(y, a);
  initial if (SELF) #1 $sdf_annotate("test_sdf_instance_array_index_b.sdf");
endmodule

module test_sdf_instance_array_index;
  reg a = 0;
  wire [1:0] ya;
  wire ys;

  sdf_aidx_wrap wa [1:0] (ya, a);
  sdf_aidx_wrap #(.SELF(1)) ws (ys, a);

  task automatic write_sdf(input string fname, input int d);
    int f;
    f = $fopen(fname, "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_aidx_cell\") (INSTANCE c)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH a y (%0d))))))", d);
    $fclose(f);
  endtask

  initial begin
    write_sdf("test_sdf_instance_array_index_a.sdf", 3);
    write_sdf("test_sdf_instance_array_index_b.sdf", 5);
    $sdf_annotate("test_sdf_instance_array_index_a.sdf", wa[1]);
    #10 a = 1;
    #10 $finish;
  end

  always @(ya or ys) if ($time >= 10) $display("%0d: ya=%b ys=%b", $time, ya, ys);
endmodule
