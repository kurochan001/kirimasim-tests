/*
:name: test_vpi_handle_release_independence
:description: Two handles to one class object compare equal and give the same vpiObjId, releasing one leaves the other valid, the object is the same while it lives, vpi_remove_cb returns 1 and the removed callback does not run while another registered callback does (IEEE 1800-2023 Sections 37.2.2, 37.2.4, 37.3.8)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.2.2 37.2.4 37.3.8 38.36.1 38.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_handle_release_independence.c
:expected_stdout: @test_vpi_handle_release_independence.expected
*/
// IEEE 1800-2023 §37.2.2: vpi_release_handle releases one handle; if a tool
// shares resources between handles, other handles that have not been released
// still refer to the object. vpi_remove_cb releases the callback handle as
// part of its action and returns 1. §37.2.4: a handle is valid from its
// creation until it is released, until its object ceases to exist, or until
// the tool terminates. §37.3.8: a handle to a transient object is acquired
// while the object lives. The class object c is created with new at time 0
// and is still referred to at time 4, so its two handles and its identifier
// are compared then, and a callback on the static variable watched is removed
// while a second one stays registered.

`timescale 1ns/1ns

module test_vpi_handle_release_independence;
  class hr_c;
    int id;
  endclass

  hr_c c;
  int watched = 0;

  initial begin
    c = new;
    c.id = 7;
    #1 $vt_release;
    #2 watched = 1;
    #3 $vt_result;
  end
endmodule
