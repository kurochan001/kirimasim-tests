/*
:name: test_vpi_routines_path_delays
:description: the routines of Table 36-6 do what it lists: vpi_get_delays reads the rise and fall delays of a module path, and vpi_put_delays writes new ones, which the later transitions of the path output then take (IEEE 1800-2023 Section 36.11)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.11 38.10 38.32 37.39 30.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_routines_path_delays.c
:expected_stdout: @test_vpi_routines_path_delays.expected
*/
// IEEE 1800-2023 §36.11, Table 36-6: vpi_get_delays retrieves the delays or
// timing limits of an object, and vpi_put_delays writes them. §38.10: for a
// path delay, two delays are read into the application's s_vpi_time array
// in the order of the description, here as vpiScaledRealTime in the time unit
// of the module, 1 ns. §38.32: vpi_put_delays sets them in the same order.
// §30.5.1: with two delays, the first is for rising and the second for
// falling transitions of the path output; the path a => y of the cell has 3
// and 4. §37.39: the path is a vpiModPath of the instance c.
// At time 5, after y has settled to 0, the application reads the delays,
// writes 7 and 9 and reads them again. a rises at 10 and falls at 30, so y
// rises at 17 and falls at 39, where the old delays would give 13 and 34.
// Under Verilator 5.052, which ignores specify blocks, there is no module path.

`timescale 1ns/1ns

module test_vpi_routines_path_delays_cell(input a, output y);
  buf b1(y, a);

  specify
    (a => y) = (3, 4);
  endspecify
endmodule

module test_vpi_routines_path_delays;
  logic a = 1'b0;
  wire y;

  test_vpi_routines_path_delays_cell c(.a(a), .y(y));

  always @(y) if ($time > 5) $display("%0t: y=%b", $time, y);

  initial begin
    #10 a = 1'b1;
    #20 a = 1'b0;
    #20 $finish;
  end
endmodule
