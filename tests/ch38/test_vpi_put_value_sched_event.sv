/*
:name: test_vpi_put_value_sched_event
:description: vpi_put_value returns a vpiSchedEvent handle only for a delayed value with vpiReturnEvent; vpiCancelEvent with NULL value and time removes only that event, keeps the events that its inertial scheduling removed removed, and is no error after the event; vpiScheduled tells whether the event is pending; vpi_release_handle leaves the event in place (IEEE 1800-2023 Section 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 38.2 38.36.2 38.36.3 K.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_value_sched_event.c
:expected_stdout: @test_vpi_put_value_sched_event.expected
*/
// IEEE 1800-2023 §38.34: with the vpiReturnEvent bit in its flags,
// vpi_put_value returns a handle of type vpiSchedEvent to the event it
// schedules with a delay; without that bit, or without a delay, it returns
// NULL. vpi_put_value on that handle with vpiCancelEvent, where value_p and
// time_p can be NULL, removes that event from the queue; whatever the
// scheduling of the event caused stays, such as the events that an inertial
// delay removed. Cancelling an event that has already occurred is not an
// error (vpi_chk_error returns 0, 38.2), and vpi_get(vpiScheduled) tells
// whether the event is still scheduled. vpi_release_handle on the handle
// frees the handle but does not affect the event.
//
// In a cbAfterDelay callback at 10 (38.36.2), registered at the start of the
// simulation (38.36.3), the application schedules with
// vpiPureTransportDelay: on a, 1 for 20 (returning its event, then cancelled)
// and 2 for 30; on c, 7 for 15 (its event kept); on d, 9 for 20 (its handle
// released at once); on e, 1 for 20, removed by 2 for 25 with
// vpiInertialDelay, whose event is then cancelled. It puts 5 into b with
// vpiNoDelay and vpiReturnEvent. A callback at 17 checks the event of c. The
// design prints the variables at 12, 22, 27 and 35.
// Icarus Verilog 13.0 has no vpiCancelEvent, vpiScheduled and vpiSchedEvent
// in its vpi_user.h (the test then uses the Annex K values) and returns NULL
// for every vpi_put_value.

`timescale 1ns/1ns

module test_vpi_put_value_sched_event;
  int a, b, c, d, e;

  initial begin
    #12 $display("12: a=%0d b=%0d c=%0d d=%0d e=%0d", a, b, c, d, e);
    #10 $display("22: a=%0d b=%0d c=%0d d=%0d e=%0d", a, b, c, d, e);
    #5 $display("27: a=%0d b=%0d c=%0d d=%0d e=%0d", a, b, c, d, e);
    #8 $display("35: a=%0d b=%0d c=%0d d=%0d e=%0d", a, b, c, d, e);
  end
endmodule
