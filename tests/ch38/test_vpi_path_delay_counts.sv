/*
:name: test_vpi_path_delay_counts
:description: vpi_get_delays reads the 1, 2, 3, 6 or 12 delays of a module path in source order, and vpi_put_delays writes a new set of the same number, which vpi_get_delays reads back (IEEE 1800-2023 Sections 38.10 and 38.32)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.10 38.32 30.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_path_delay_counts.c
:expected_stdout: @test_vpi_path_delay_counts.expected
*/
// IEEE 1800-2023 §38.10: vpi_get_delays reads the delays of an object into an
// s_vpi_delay structure and an array of s_vpi_time that the application
// allocates before the call; for a path delay object no_of_delays is 1, 2, 3,
// 6 or 12, and the delays come back in the order of the source description,
// here the rise, fall, turn-off and further transition delays of 30.5.1.
// §38.32: vpi_put_delays writes delays of the same number, in the same order,
// and vpi_get_delays reads them back.
//
// Five cells each have one path with a different number of delay expressions:
// 1; 2; 3; 6; and 12. The application reads each path with its own number of
// delays and writes 100, 101, ... in that order, then reads it again. The
// time unit is 1 ns, and the delays are read as vpiScaledRealTime.

`timescale 1ns/1ns

module test_vpi_path_delay_counts_p1 (input a, output y);
  buf g (y, a);
  specify
    (a => y) = 1;
  endspecify
endmodule

module test_vpi_path_delay_counts_p2 (input a, output y);
  buf g (y, a);
  specify
    (a => y) = (2, 3);
  endspecify
endmodule

module test_vpi_path_delay_counts_p3 (input a, output y);
  buf g (y, a);
  specify
    (a => y) = (4, 5, 6);
  endspecify
endmodule

module test_vpi_path_delay_counts_p6 (input a, output y);
  buf g (y, a);
  specify
    (a => y) = (7, 8, 9, 10, 11, 12);
  endspecify
endmodule

module test_vpi_path_delay_counts_p12 (input a, output y);
  buf g (y, a);
  specify
    (a => y) = (13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24);
  endspecify
endmodule

module test_vpi_path_delay_counts;
  logic a = 1'b0;
  wire y1, y2, y3, y6, y12;

  test_vpi_path_delay_counts_p1 c1 (a, y1);
  test_vpi_path_delay_counts_p2 c2 (a, y2);
  test_vpi_path_delay_counts_p3 c3 (a, y3);
  test_vpi_path_delay_counts_p6 c6 (a, y6);
  test_vpi_path_delay_counts_p12 c12 (a, y12);

  initial begin
    #1 $vt_read;
    #1 $finish;
  end
endmodule
