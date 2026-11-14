/*
:name: test_vpi_value_change_array_member_index
:description: A cbValueChange callback on a member of an unpacked array gets the value of that member and, in index, its index in the rightmost unpacked range of the declaration, and vpi_iterate(vpiIndex) on the member gives all its indices, for a two-dimensional and a one-dimensional array (IEEE 1800-2023 Section 38.36.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_value_change_array_member_index.c
:expected_stdout: @test_vpi_value_change_array_member_index.expected
*/
// IEEE 1800-2023 §38.36.1: when the object of a cbValueChange callback has
// the property vpiArrayMember TRUE, the value passed to the callback is the
// value of the array member that changed, and the index field holds its index
// in the rightmost range of the array declaration; vpi_iterate(vpiIndex) on
// the object gives all its indices.
//
// At time 1, in a cbAfterDelay callback registered at the start of the
// simulation, the application gets the members m[1][6] and m[2][4] of the
// two-dimensional array m with vpi_handle_by_multi_index and the member w[2]
// of the one-dimensional array w, whose range descends, with
// vpi_handle_by_index, and places a cbValueChange callback with vpiIntVal
// and vpiSimTime on each. The design writes m[1][6] at 10, m[0][5], which has
// no callback, at 11, m[2][4] at 12 and w[2] at 13. Each callback prints the
// time, the member, the value, the index field, vpiArrayMember of its object
// and the indices that vpi_iterate(vpiIndex) gives, in increasing order, as
// the clause gives no order for the members of an array variable. The
// release 13.0 of Icarus Verilog has neither vpi_handle_by_multi_index nor
// vpiArrayMember; the 5.054 release of Verilator calls the routines with
// the index 0 and stops at vpi_get(vpiArrayMember). The expected output
// follows the clause alone.

`timescale 1ns/1ns

module test_vpi_value_change_array_member_index;
  logic [7:0] m [0:2][4:7];
  logic [7:0] w [3:1];

  initial begin
    #10 m[1][6] = 8'h42;
    #1 m[0][5] = 8'h01;
    #1 m[2][4] = 8'h17;
    #1 w[2] = 8'h09;
    #1 $finish;
  end
endmodule
