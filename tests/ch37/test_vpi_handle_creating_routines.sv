/*
:name: test_vpi_handle_creating_routines
:description: Handles created by vpi_handle, vpi_handle_by_index, vpi_handle_by_name, vpi_handle_multi, vpi_iterate, vpi_scan, vpi_register_cb and vpi_register_systf refer to the expected objects, and two VPI programs keep their own handles to one object when one of them releases its handle (IEEE 1800-2023 Section 37.2.1)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.2.1 37.2.2 37.2.3 37.37 37.42 38.12 38.19 38.21 38.22 38.32 38.38
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_handle_creating_routines.c
:expected_stdout: @test_vpi_handle_creating_routines.expected
*/
// IEEE 1800-2023 §37.2.1 lists the routines that create handles. The C file
// holds two VPI programs, A and B, each with its own system tasks and its own
// handles. A gets mem[2] by index (38.19) and by name (38.21), the instance s
// by name and by scanning the instances of the module, and the module of the
// net w with vpi_handle, and compares them with vpi_compare_objects (§37.2.3).
// An iterator from vpi_iterate has type vpiIterator and a handle from
// vpi_register_cb type vpiCallback. vpi_get_systf_info (38.12) on the handle
// that vpi_register_systf returned for $vt_a, and on the systf that the call
// of $vt_a leads to (37.42 detail 5), names $vt_a. §37.37: vpi_handle_multi
// gives the intermodule path associated with the output port of s and the
// input port of t (38.22); its ports are those two ports, and its delays read
// back as put with vpi_put_delays (38.32, 38.10).
// §37.2.1, §37.2.2: A and B both get a handle to count; after A releases its
// own (38.38 returns 1), B still reads count through its handle at time 2.

`timescale 1ns/1ns

module test_vpi_handle_creating_routines_src(output wire o, input wire d);
  assign o = d;
endmodule

module test_vpi_handle_creating_routines_dst(input wire i, output wire q);
  assign q = i;
endmodule

module test_vpi_handle_creating_routines;
  logic [7:0] mem [0:3];
  int count = 0;
  logic d = 0;
  wire w, q;

  test_vpi_handle_creating_routines_src s(.o(w), .d(d));
  test_vpi_handle_creating_routines_dst t(.i(w), .q(q));

  initial begin
    for (int k = 0; k < 4; k++) mem[k] = 8'h10 + k;
    count = 5;
    #1 $vt_a;
    $vt_b_get;
    $vt_a_release;
    count = 6;
    #1 $vt_b_read;
    $display("mem[2]=%h", mem[2]);
  end
endmodule
