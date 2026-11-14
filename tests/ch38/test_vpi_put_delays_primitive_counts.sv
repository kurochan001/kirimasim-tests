/*
:name: test_vpi_put_delays_primitive_counts
:description: vpi_put_delays sets the delays of a primitive with no_of_delays 2, the rise and fall delays of an and gate, and with no_of_delays 3, the rise, fall and turn-off delays of a bufif1 gate, and the gates then switch with the new delays (IEEE 1800-2023 Section 38.32)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.32 38.10 28.16
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_put_delays_primitive_counts.c
:expected_stdout: @test_vpi_put_delays_primitive_counts.expected
*/
// IEEE 1800-2023 §38.32: for a primitive, the no_of_delays of vpi_put_delays
// is 2 or 3, and the da array holds the delays in the order of the source
// description, which for a gate (28.16) is the rise, the fall and the
// turn-off delay. §38.10: vpi_get_delays reads them in the same order. A
// change to 1 takes the rise delay, a change to 0 the fall delay and a change
// to z the turn-off delay.
//
// At 8, in a cbAfterDelay callback registered at the start of the
// simulation, the application reads the delays of the and gate g2 with
// no_of_delays 2 and of the bufif1 gate g3 with no_of_delays 3, as
// vpiScaledRealTime in the time unit 1 ns, sets g2 to 7 and 9 and g3 to 5, 8
// and 11, and reads them again. Then g2 rises 7 after 10 and falls 9 after
// 30; g3, enabled at 10 with the data 0, goes to 0 8 after 10, rises 5 after
// 40, falls 8 after 50 and goes to z 11 after it is disabled at 60. The
// design prints the outputs when they change after 8. The release 13.0 of
// Icarus Verilog finds no gate by its name, and the 5.054 release of
// the Verilator simulator does not build the bufif1 gate, so the expected
// output follows the clauses alone.

`timescale 1ns/1ns

module test_vpi_put_delays_primitive_counts;
  logic a = 0, b = 0, d = 0, en = 0;
  wire y2, y3;

  and #(3, 5) g2 (y2, a, b);
  bufif1 #(2, 4, 6) g3 (y3, d, en);

  always @(y2) if ($time > 8) $display("%0d: y2 = %b", $time, y2);
  always @(y3) if ($time > 8) $display("%0d: y3 = %b", $time, y3);

  initial begin
    #10 a = 1;
    b = 1;
    en = 1;
    #20 b = 0;
    #10 d = 1;
    #10 d = 0;
    #10 en = 0;
    #20 $finish;
  end
endmodule
