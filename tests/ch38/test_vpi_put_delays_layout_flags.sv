/*
:name: test_vpi_put_delays_layout_flags
:description: vpi_put_delays takes the delays of a module path in source order, with the da array laid out by mtm_flag and pulsere_flag, and keeps the pulse limits when only the delays change (IEEE 1800-2023 Section 38.32)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.32 38.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_delays_layout_flags.c
:expected_stdout: @test_vpi_put_delays_layout_flags.expected
*/
// IEEE 1800-2023 §38.32: vpi_put_delays sets the delays and pulse limits of an
// object from an s_vpi_delay and an application-allocated array of s_vpi_time.
// With mtm_flag FALSE and pulsere_flag TRUE each delay is followed by its
// reject and error limits, with mtm_flag TRUE and pulsere_flag FALSE by its
// min, typ and max, and with both flags by the nine values of Table 38-2. The
// delays come in the order of the description, and a put that changes only the
// delays keeps the limits set before. The application writes the two delays
// 5 and 8 with the limits 2 and 3, then the min, typ and max values 5 6 7 and
// 8 9 10, then the 18 values 1 to 18, and reads each back with vpi_get_delays
// in the same layout. Last, it sets the delays 11 and 13 alone and reads the
// limits back, which are still 2 and 3. The release 13.0 of Icarus Verilog
// flattens the min:typ:max and pulse limit values, so the expected output
// follows the clauses alone.

`timescale 1ns/1ns

module test_vpi_put_delays_layout_flags (
  input logic a,
  input logic b,
  output logic y
);
  assign y = a & b;

  specify
    (a => y) = (4, 6);
    (b => y) = (8, 10);
  endspecify

  initial begin
    #1 $vt_put;
    $finish;
  end
endmodule
