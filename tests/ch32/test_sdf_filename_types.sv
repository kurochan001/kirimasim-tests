/*
:name: test_sdf_filename_types
:description: The file name argument of $sdf_annotate can be a string literal, a variable of the string type or an integral variable that holds the characters of the name (IEEE 1800-2023 Section 32.9)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.9 32.6 32.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_filename_types.expected
*/
// IEEE 1800-2023 §32.9: the first argument of $sdf_annotate, sdf_file, is a
// string literal, an expression of the string data type, or an integral
// expression that holds a character string, naming the file to open. Three
// SDF files give the path a => y of the cell c the delays 2, 3 and 4
// (32.4.1). The first is named by a string literal, the second by a string
// variable and the third, in the call of $sdf_annotate, by a 232-bit reg
// that holds exactly the 29 characters of its name; each call annotates its
// own wrapper, w1, w2 or w3, given as the module_instance argument (32.6).
// When a rises at 10, y1, y2 and y3 follow at 12, 13 and 14. Verilator
// 5.052 ignores $sdf_annotate and module path delays.

`timescale 1ns/1ns

module sdf_fname_cell(output y, input a);
  buf (y, a);
  specify
    (a => y) = 1;
  endspecify
endmodule

module sdf_fname_wrap(output y, input a);
  sdf_fname_cell c(y, a);
endmodule

module test_sdf_filename_types;
  reg a = 0;
  wire y1, y2, y3;
  string name2 = "test_sdf_filename_types_2.sdf";
  reg [8*29:1] name3 = "test_sdf_filename_types_3.sdf";

  sdf_fname_wrap w1(y1, a);
  sdf_fname_wrap w2(y2, a);
  sdf_fname_wrap w3(y3, a);

  task automatic write_sdf(input string fname, input int d);
    int f;
    f = $fopen(fname, "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_fname_cell\") (INSTANCE c)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH a y (%0d))))))", d);
    $fclose(f);
  endtask

  initial begin
    write_sdf("test_sdf_filename_types_1.sdf", 2);
    write_sdf(name2, 3);
    write_sdf("test_sdf_filename_types_3.sdf", 4);
    $sdf_annotate("test_sdf_filename_types_1.sdf", w1);
    $sdf_annotate(name2, w2);
    $sdf_annotate(name3, w3);
    #10 a = 1;
    #10 $finish;
  end

  always @(y1 or y2 or y3) if ($time >= 10) $display("%0d: y1=%b y2=%b y3=%b", $time, y1, y2, y3);
endmodule
