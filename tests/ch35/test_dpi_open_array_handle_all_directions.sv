/*
:name: test_dpi_open_array_handle_all_directions
:description: Open array formals of direction input, output and inout all reach C as svOpenArrayHandle, a void pointer, and are read and written only through the svdpi.h functions, the output ones with room for exactly the elements of the actual, while the other formals of the same call are passed by value or by direct reference (IEEE 1800-2023 Section 35.5.6.1, H.12, H.8.6, H.8.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 H.12 H.8.6 H.8.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_open_array_handle_all_directions.c
:expected_stdout: @test_dpi_open_array_handle_all_directions.expected
*/
// IEEE 1800-2023 H.12, H.8.6: an open array formal is passed by a handle
// whatever its direction: svOpenArrayHandle, a void pointer whose meaning is
// the tool's, given as a const argument, and reached only through the
// functions of svdpi.h, such as svGetArrayPtr for the address of the array.
// For an output or inout open array the room the C code can write into is the
// size of the actual. H.8.1: the formals that are not open arrays are reached
// directly: a small input by value, the others by reference.
//
// c_dirs gets the input i[1:3], the output o[4:0], the inout io[0:1], the
// output ol[2:3] of logic [7:0] and the inout ib[0:2] of bit as handles, and
// the input int n by value, the output int on and the inout bit [7:0] ion by
// pointer. It sums i through element addresses, prints 1 when svGetArrayPtr
// is NULL or gives the same elements, writes 7*k to each o[k], adds 1000 to
// each io element, puts a5 and 3c into ol, inverts ib, and writes n + 1 to on
// and the complement of ion back to ion. c_fill is called with outputs of 2
// and 5 elements and writes 100 + k to each of the svSize(h, 1) elements, all
// that the actual holds. The C code also prints 1 when svOpenArrayHandle is
// exactly void *, compared at compile time (C11 _Generic in C, a template in
// C++).
//
// Icarus Verilog 13.0 has no DPI.

module test_dpi_open_array_handle_all_directions;
  import "DPI-C" function void c_dirs(input int i [], output int o [], inout int io [],
                                      output logic [7:0] ol [], inout bit ib [],
                                      input int n, output int on, inout bit [7:0] ion);
  import "DPI-C" function void c_fill(output int f []);

  int i [1:3];
  int o [4:0];
  int io [0:1];
  logic [7:0] ol [2:3];
  bit ib [0:2];
  int on;
  bit [7:0] ion;
  int f2 [1:2];
  int f5 [9:5];

  initial begin
    i = '{5, 6, 7};
    io = '{1, 2};
    ib = '{1'b1, 1'b0, 1'b1};
    ion = 8'h0f;
    c_dirs(i, o, io, ol, ib, 41, on, ion);
    $display("o %0d %0d %0d %0d %0d", o[4], o[3], o[2], o[1], o[0]);
    $display("io %0d %0d, ol %h %h, ib %b%b%b", io[0], io[1], ol[2], ol[3], ib[0], ib[1], ib[2]);
    $display("on %0d, ion %h", on, ion);
    c_fill(f2);
    c_fill(f5);
    $display("f2 %0d %0d, f5 %0d %0d %0d %0d %0d", f2[1], f2[2], f5[9], f5[8], f5[7], f5[6],
             f5[5]);
  end
endmodule
