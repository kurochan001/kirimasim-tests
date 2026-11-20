/*
:name: test_vpi_delay_buffer_count_flag_matrix
:description: Application-owned delay buffers have capacity for each legal module-path delay count crossed with both min/typ/max and pulse-limit flags (IEEE 1800-2023 Section 38.10)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.10 30.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_delay_buffer_count_flag_matrix.c
:expected_stdout: @test_vpi_delay_buffer_count_flag_matrix.expected
*/
// 38.10 B017-B026 requires count, 3*count, or 9*count application-owned
// s_vpi_time entries according to no_of_delays and the two format flags.
// Five distinct cells supply the legal path counts 1,2,3,6,12. Every cell
// is read with all four flag combinations. Its kth source delay is
// 10*count+k+1, and PATHPULSE gives reject=2, error=4 (30.7.1).
// Scalar delay/limit expressions have the same min,typ,max values, so
// no invocation-dependent min/typ/max choice affects any expected number.
// The C application computes each required capacity before allocating its
// own array with one guard entry on either side. It prints every required
// value from that original allocation, pointer identity, and both guards.
// Thus count or flag sizing errors leave missing or misplaced values, and
// overwriting the required extent changes a guard. Each cell has exactly
// one module path; no relative iteration order among paths is assumed.
// Icarus Verilog 13.0 does not fill the requested pulse-limit entries:
// the first three-entry case lacks the specified reject=2 and error=4.
// The common expected output retains the standard values. The 5.054
// release of the Verilator simulator does not run the registered task.

`timescale 1ns/1ns

module test_vpi_delay_buffer_count_flag_matrix_p1(input a, output y);
  buf gate (y, a);
  specify
    specparam PATHPULSE$a$y = (2, 4);
    (a => y) = 11;
  endspecify
endmodule

module test_vpi_delay_buffer_count_flag_matrix_p2(input a, output y);
  buf gate (y, a);
  specify
    specparam PATHPULSE$a$y = (2, 4);
    (a => y) = (21, 22);
  endspecify
endmodule

module test_vpi_delay_buffer_count_flag_matrix_p3(input a, output y);
  buf gate (y, a);
  specify
    specparam PATHPULSE$a$y = (2, 4);
    (a => y) = (31, 32, 33);
  endspecify
endmodule

module test_vpi_delay_buffer_count_flag_matrix_p6(input a, output y);
  buf gate (y, a);
  specify
    specparam PATHPULSE$a$y = (2, 4);
    (a => y) = (61, 62, 63, 64, 65, 66);
  endspecify
endmodule

module test_vpi_delay_buffer_count_flag_matrix_p12(input a, output y);
  buf gate (y, a);
  specify
    specparam PATHPULSE$a$y = (2, 4);
    (a => y) = (121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132);
  endspecify
endmodule

module test_vpi_delay_buffer_count_flag_matrix;
  logic a = 0;
  wire y1, y2, y3, y6, y12;

  test_vpi_delay_buffer_count_flag_matrix_p1 p1(a, y1);

  test_vpi_delay_buffer_count_flag_matrix_p2 p2(a, y2);

  test_vpi_delay_buffer_count_flag_matrix_p3 p3(a, y3);

  test_vpi_delay_buffer_count_flag_matrix_p6 p6(a, y6);

  test_vpi_delay_buffer_count_flag_matrix_p12 p12(a, y12);

  initial begin
    #1 $vt_delay_matrix;
    #1 $finish;
  end
endmodule
