/*
:name: test_vpi_get_delays_tchk_limit_counts
:description: vpi_get_delays reads a timing check with no_of_delays equal to its number of limits, one for $setup and two for $setuphold and $recrem, and returns the limits in source order without writing past them (IEEE 1800-2023 Section 38.10)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_delays_tchk_limit_counts.c
:expected_stdout: @test_vpi_get_delays_tchk_limit_counts.expected
*/
// IEEE 1800-2023 §38.10: for a timing check object, no_of_delays of
// vpi_get_delays is the number of limits that the check has, and the da
// array holds them in the order of the source description. $setup has one
// limit, while $setuphold (setup and hold limit) and $recrem (recovery and
// removal limit) have two (31.2).
//
// The cell has the three checks with the limits 3; 4 and 5; 6 and 7, in
// the time unit 1 ns. The application finds each check by its vpiTchkType,
// so the order of the iteration does not matter, reads it with its own
// number of limits and no flag, as vpiScaledRealTime, and prints the limits.
// The da array has room for eight elements whose bytes are all 0xA5 before
// the call; the application also prints whether the elements after the
// limits still hold that pattern. The inputs stay constant, and no
// reference event of a check occurs, so no check reports a violation. The
// release 13.0 of Icarus Verilog does not support timing checks, and its
// vpi_user.h lacks vpiTchk and the vpiTchkType constants; the 5.054
// release of Verilator ignores specify blocks. The expected output follows
// the clause alone.

`timescale 1ns/1ns

module test_vpi_get_delays_tchk_limit_counts_cell (input clk, d, rst);
  specify
    $setup(d, posedge clk, 3);
    $setuphold(posedge clk, d, 4, 5);
    $recrem(negedge rst, posedge clk, 6, 7);
  endspecify
endmodule

module test_vpi_get_delays_tchk_limit_counts;
  logic clk = 1'b0, d = 1'b0, rst = 1'b1;

  test_vpi_get_delays_tchk_limit_counts_cell u1 (clk, d, rst);

  initial #1 $vt_limits;
endmodule
