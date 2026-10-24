/*
:name: test_vpi_put_value_delay_modes_queue
:description: With two values already scheduled on an object at 20 and 40, vpi_put_value of a value at 30 removes both with vpiInertialDelay, only the later one with vpiTransportDelay and neither with vpiPureTransportDelay (IEEE 1800-2023 Section 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 38.36.2 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_value_delay_modes_queue.c
:expected_stdout: @test_vpi_put_value_delay_modes_queue.expected
*/
// IEEE 1800-2023 §38.34: vpi_put_value with vpiInertialDelay removes all the
// events scheduled on the object before it schedules the new one; with
// vpiTransportDelay it removes only those scheduled for times later than the
// new one (modified transport); with vpiPureTransportDelay it removes none.
// In a cbAfterDelay callback at 10 (38.36.2), registered at the start of the
// simulation (38.36.3), the application schedules on each of in_v, tr_v and
// pt_v the value 1 for 20 and 2 for 40 with vpiPureTransportDelay, and then 3
// for 30 with the mode that the name of the variable gives. The design prints
// the variables at 25, 35 and 45, between the scheduled times.
// Icarus Verilog 13.0 keeps the earlier events in all three modes.

`timescale 1ns/1ns

module test_vpi_put_value_delay_modes_queue;
  int in_v, tr_v, pt_v;

  initial begin
    #25 $display("25: in_v=%0d tr_v=%0d pt_v=%0d", in_v, tr_v, pt_v);
    #10 $display("35: in_v=%0d tr_v=%0d pt_v=%0d", in_v, tr_v, pt_v);
    #10 $display("45: in_v=%0d tr_v=%0d pt_v=%0d", in_v, tr_v, pt_v);
  end
endmodule
