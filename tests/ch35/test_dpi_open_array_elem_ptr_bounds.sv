/*
:name: test_dpi_open_array_elem_ptr_bounds
:description: svGetArrElemPtr and svGetArrElemPtr1, 2 and 3 give the address of the element of an open array with int, real and shortint elements that the SystemVerilog indices select, through which C reads and writes it, and NULL for an index outside the range of its dimension (IEEE 1800-2023 Section 35.5.6.1, H.12.4)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 H.12.4 H.12.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_open_array_elem_ptr_bounds.c
:expected_stdout: @test_dpi_open_array_elem_ptr_bounds.expected
*/
// IEEE 1800-2023 §35.5.6.1: the unsized unpacked dimensions of an open array
// formal take the ranges of the actual. H.12.3: an element of a type other
// than a packed or scalar bit or logic is reached through its address, with
// the SystemVerilog indices. H.12.4: svGetArrElemPtr (one index per
// dimension) and svGetArrElemPtr1, 2 and 3 return the address of the element,
// and NULL when an index is outside the range of its dimension; the address
// is a generic pointer, which the C code casts to the C type of the element
// (int, double, short int: H.7.4), and the addresses of individual elements
// are always given for such types.
//
// c_elems tries indices inside each range and one step outside each bound,
// for the descending a[5:2], the mixed r[0:1][3:1] and the
// three-dimensional s[1:2][2:1][0:1]. For an index inside, it prints the value
// read through the address, prints 1 when svGetArrElemPtr gives the same
// address as the specialized function, and changes the element through it;
// for an index outside, it prints NULL and 1 when svGetArrElemPtr is NULL too.
// The design then prints the elements, which show the writes of the C code.
//
// Icarus Verilog 13.0 has no DPI. In Verilator 5.052 every index of an open
// array of real gives the address of its first element, so all four reads of
// r see r[0][1], and each index outside a range also prints a warning on
// standard output; :oracle: names no simulator.

module test_dpi_open_array_elem_ptr_bounds;
  import "DPI-C" function void c_elems(inout int a [], inout real r [][], inout shortint s [][][]);

  int a [5:2];
  real r [0:1][3:1];
  shortint s [1:2][2:1][0:1];

  initial begin
    foreach (a[i]) a[i] = i * 10;
    foreach (r[i, j]) r[i][j] = i * 10 + j + 0.5;
    foreach (s[i, j, k]) s[i][j][k] = shortint'(i * 100 + j * 10 + k);
    c_elems(a, r, s);
    $display("a[5] %0d a[4] %0d a[3] %0d a[2] %0d", a[5], a[4], a[3], a[2]);
    $display("r[0][3] %0.1f r[0][1] %0.1f r[1][2] %0.1f r[1][1] %0.1f", r[0][3], r[0][1],
             r[1][2], r[1][1]);
    $display("s[1][2][0] %0d s[2][1][1] %0d s[2][2][0] %0d s[1][1][1] %0d", s[1][2][0],
             s[2][1][1], s[2][2][0], s[1][1][1]);
  end
endmodule
