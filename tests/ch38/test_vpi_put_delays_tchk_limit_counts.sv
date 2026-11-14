/*
:name: test_vpi_put_delays_tchk_limit_counts
:description: vpi_put_delays sets the limits of a timing check with no_of_delays equal to its number of limits, one for $hold and two for $setuphold and $recrem, in source order, and vpi_get_delays then reads the new limits (IEEE 1800-2023 Section 38.32)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.32 38.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_delays_tchk_limit_counts.c
:expected_stdout: @test_vpi_put_delays_tchk_limit_counts.expected
*/
// IEEE 1800-2023 §38.32: for a timing check, the no_of_delays of
// vpi_put_delays equals the number of limits the check has, and the da array
// holds the new limits in the order of the source description. $hold has one
// limit, $setuphold a setup and a hold limit and $recrem a recovery and a
// removal limit (31.2). §38.10: vpi_get_delays reads the limits in the same
// order with the same number.
//
// The cell has the checks with the limits 3; 4 and 5; 6 and 7, in the time
// unit 1 ns. At 1, in a cbAfterDelay callback registered at the start of the
// simulation, the application finds each check by its vpiTchkType, so that
// the order of the iteration does not matter, reads its limits as
// vpiScaledRealTime with its number of limits, sets them to 8; 9 and 10; 11
// and 12 with the same number, and reads them again. The inputs stay
// constant and no reference event of a check occurs, so no check reports a
// violation. The release 13.0 of Icarus Verilog has no vpiTchk constants in
// its vpi_user.h, and the 5.054 release of Verilator gives no timing check
// objects, so the expected output follows the clauses alone.

`timescale 1ns/1ns

module test_vpi_put_delays_tchk_limit_counts_cell (input clk, d, rst);
  specify
    $hold(posedge clk, d, 3);
    $setuphold(posedge clk, d, 4, 5);
    $recrem(negedge rst, posedge clk, 6, 7);
  endspecify
endmodule

module test_vpi_put_delays_tchk_limit_counts;
  logic clk = 1'b0, d = 1'b0, rst = 1'b1;

  test_vpi_put_delays_tchk_limit_counts_cell u1 (clk, d, rst);

  initial #2 $finish;
endmodule
