/*
:name: test_vpi_callback_memory_index
:description: A cbValueChange callback on a memory reports in index the word that changed, in value the value of that word, and in a new s_cb_data structure, whose data the application copies before it returns (IEEE 1800-2023 Sections 38.8 and 38.36.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.8 38.36.1 38.36 38.15 38.13
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_callback_memory_index.c
:expected_stdout: @test_vpi_callback_memory_index.expected
*/
// IEEE 1800-2023 §38.8: the s_cb_data structure that a callback receives has
// the reason, the routine, the trigger object, the time, the value, an index
// that identifies the memory word or variable select that changed, and the
// user data. §38.36.1: a cbValueChange callback occurs after a value change,
// and it receives a new s_cb_data structure, not the one given to
// vpi_register_cb; the structures it points to belong to the simulator, so
// data needed later is copied before the routine returns.
//
// The application registers one cbValueChange callback on the memory mem at
// time 1, with the format vpiHexStrVal, the time type vpiSimTime and the user
// data "mem". mem[2] gets 55 at time 2 and mem[0] gets aa at time 3. Each
// callback prints the index, the value, the time, whether its structure is a
// new one, and the user data, and copies the value string to a buffer that
// $vt_done prints at time 5.

`timescale 1ns/1ns

module test_vpi_callback_memory_index;
  logic [7:0] mem [0:3];

  initial begin
    #1 $vt_watch;
    #1 mem[2] = 8'h55;
    #1 mem[0] = 8'haa;
    #2 $vt_done;
  end
endmodule
