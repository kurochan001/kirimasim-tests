/*
:name: test_vpi_static_handle_lifetime
:description: A handle to a static object stays valid from its creation until it is released, and refers to the same object for the whole simulation (IEEE 1800-2023 Section 37.2.4)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.2.4 37.3.7 38.2 38.31
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_static_handle_lifetime.c
:expected_stdout: @test_vpi_static_handle_lifetime.expected
*/
// IEEE 1800-2023 §37.2.4: a handle is valid from its creation until it is
// released or its object ceases to exist. §37.3.7: an object of the static
// design hierarchy exists for the whole simulation. $vt_keep gets a handle to
// count at time 0; at 11 $vt_use reads count through it, compares it with a new
// handle (38.2) and releases both with vpi_release_handle (38.31), which
// returns 1 for success.

`timescale 1ns/1ns

module test_vpi_static_handle_lifetime;
  int count = 0;

  initial begin
    $vt_keep;
    #10 count = 7;
    #1 $vt_use;
  end
endmodule
