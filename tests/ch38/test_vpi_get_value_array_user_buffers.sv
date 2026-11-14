/*
:name: test_vpi_get_value_array_user_buffers
:description: with vpiUserAllocFlag vpi_get_value_array fills an application buffer of exactly the size the clause gives for each format and nothing past it, an error sets the value pointer to NULL in both allocation modes, and without the flag VPI supplies the storage, which the application copies (IEEE 1800-2023 Section 38.16)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_value_array_user_buffers.c
:expected_stdout: @test_vpi_get_value_array_user_buffers.expected
*/
// IEEE 1800-2023 §38.16: when the application sets vpiUserAllocFlag in
// flags, the value member points to its own buffer, and the values go
// there. For the formats other than the raw and vector ones the buffer
// holds num items of the type that the union member points to; for
// vpiVectorVal it holds ((bits + 31) / 32) * 2 * num 32-bit words, A/B
// pairs of each element; for vpiRawFourStateVal ngroups * num * 2 bytes and
// for vpiRawTwoStateVal ngroups * num bytes, with ngroups = (bits + 7) / 8.
// Without the flag VPI allocates the storage, which a later call may reuse,
// so an application copies what it keeps. A NULL value pointer after the
// call means that an error occurred, whichever side allocated the storage;
// the application still frees its own buffer, through a pointer it kept.
//
// Every array has four elements, and the application reads three of them from
// index 1 in each of the nine formats into a buffer that it allocates with
// exactly the size above plus 16 more bytes, all set to 0xA5. It prints whether
// the value pointer is still its buffer, the values read from the buffer
// through its own pointer, and whether the 16 bytes after the computed size
// still hold 0xA5. The bits above an element's width in its last word or byte
// are masked out, since the clause does not fix them. Then it asks for
// vpiShortIntVal on the int array with its own buffer, which the clause allows
// only for byte and shortint elements, and, with VPI storage, for
// vpiShortRealVal, allowed only for shortreal elements, and vpiStringVal, which
// the clause does not list; all three pointers come back NULL. Last it reads ia
// with VPI storage, copies the three values, reads ra, and prints the copy. The
// release 13.0 of Icarus Verilog has no s_vpi_arrayvalue in its vpi_user.h, and
// the 5.054 release of Verilator stops the run at vpiUserAllocFlag, and at a
// format it does not support instead of returning NULL, so the expected output
// follows the clause alone.

`timescale 1ns/1ns

module test_vpi_get_value_array_user_buffers;
  int ia[0:3];
  shortint sa[0:3];
  longint la[0:3];
  real ra[0:3];
  shortreal fa[0:3];
  time ta[0:3];
  logic [39:0] wa[0:3];
  logic [11:0] xa[0:3];
  bit [11:0] ba[0:3];

  initial begin
    ia = '{5, -6, 7, 8};
    sa = '{1, -2, 300, 4};
    la = '{1, 64'sh1_0000_0002, -3, 4};
    ra = '{0.5, 1.25, -2.5, 3.75};
    fa = '{0.5, -1.5, 2.25, 4.0};
    ta = '{1, 64'h2_0000_0003, 4, 5};
    wa = '{40'h0, 40'h12_3456_789a, 40'hab_0000_0001, 40'h1};
    xa = '{12'h000, 12'habc, 12'h123, 12'hfed};
    ba = '{12'h000, 12'h456, 12'h789, 12'hcde};
  end

  initial #5 $display("design done");
endmodule
