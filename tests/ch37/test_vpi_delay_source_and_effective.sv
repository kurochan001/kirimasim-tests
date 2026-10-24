/*
:name: test_vpi_delay_source_and_effective
:description: vpiDelay gives the delays written in the source, a constant for one and a list operation for two, while vpi_get_delays gives the delays in use, which vpi_put_delays changes without changing vpiDelay; vpi_put_value and vpi_get_value write and read a value through s_vpi_value (IEEE 1800-2023 Section 37.3.4)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.4 38.10 38.32 38.15 38.34 28.16
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_delay_source_and_effective.c
:expected_stdout: @test_vpi_delay_source_and_effective.expected
*/
// IEEE 1800-2023 §37.3.4: delays and values need routines with structures:
// vpi_get_delays and vpi_put_delays with s_vpi_delay (38.10, 38.32), and
// vpi_get_value and vpi_put_value with s_vpi_value (38.15, 38.34). vpiDelay
// gives the delay expressions written in the source: one expression that
// evaluates to a constant for a single delay, and an operation of type
// vpiListOp for several; vpi_get_delays gives the delays the tool actually
// uses. At the start of the simulation the application reads the source
// delays of g1 (#3) and g2 (#(2, 4)), reads the delays of g1, sets them to
// 7 and 7 (rise and fall, 28.16) with vpi_put_delays, reads them again, and
// reads vpiDelay of g1 once more, which still gives the source delay 3. It
// also puts 60 (8'h3c) into r and reads it back. a becomes 0 at 0 and 1 at
// 10, so y1 follows at 7 and 17, with the new delays, and y2 at 4 (fall) and
// 12 (rise); the values are printed at fixed times. The VPI headers of
// Icarus Verilog 13.0 lack constants used here, and in Icarus Verilog 13.0
// and Verilator 5.052 vpi_handle_by_name does not find the gates.

`timescale 1ns/1ns

module test_vpi_delay_source_and_effective;
  logic a;
  logic [7:0] r;
  wire y1, y2;

  buf #3 g1 (y1, a);
  buf #(2, 4) g2 (y2, a);

  initial begin
    a = 1'b0;
    #10 a = 1'b1;
  end

  initial begin
    #5 $display("%0t: y1=%b y2=%b r=%h", $time, y1, y2, r);
    #3 $display("%0t: y1=%b y2=%b", $time, y1, y2);
    #7 $display("%0t: y1=%b y2=%b", $time, y1, y2);
    #3 $display("%0t: y1=%b y2=%b", $time, y1, y2);
  end
endmodule
