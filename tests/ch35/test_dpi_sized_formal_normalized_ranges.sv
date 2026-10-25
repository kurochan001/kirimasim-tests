/*
:name: test_dpi_sized_formal_normalized_ranges
:description: C sees the sized formals of an import with normalized ranges, packed [n-1:0] with the MSB of an ascending range as bit n-1 and unpacked [0:n-1] in C layout with the lowest SystemVerilog index first, while an open array formal keeps the original unpacked range and indices and reports a normalized packed range (IEEE 1800-2023 Section 35.5.6, H.11, H.7.6)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.11 H.11.4 H.7.3 H.7.5 H.7.6 H.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_sized_formal_normalized_ranges.c
:expected_stdout: @test_dpi_sized_formal_normalized_ranges.expected
*/
// IEEE 1800-2023 H.11, H.7.5, H.2: C code reaches array arguments through
// normalized ranges, [n-1:0] for the packed part, linearized when it has
// several dimensions, and [0:n-1] for each unpacked dimension; only the
// unpacked dimensions of open array formals keep the SystemVerilog ranges,
// which the query functions return together with a normalized packed range.
// H.7.6 b: a packed [L:R] becomes [abs(L-R):0] with its MSB at abs(L-R).
// H.7.3, H.7.6 c: in an unpacked dimension the element with the index
// min(L,R) has the C index 0 and the one with max(L,R) the C index abs(L-R).
// H.11.4: unpacked arrays other than open array formals have the C layout and
// are indexed as in C. The actuals have the same types as the sized formals
// (35.5.6 lets a tool restrict other actuals of a sized array formal).
//
// c_sized prints the two elements of y[2:1] in C order, y[1] first; the bits
// 5 and 0 of z[0:5], which are z[0] and z[5]; the nine elements of
// u[1:3][2:0] in C order, which starts with u[1][0], u[1][1], u[1][2]; and it
// writes 100, 200 and 300 to ou[3:1] in C order, so ou[1] gets 100. c_open
// receives y through an open array formal: dimension 1 keeps the range 2:1
// and index 2 reaches y[2], and dimension 0 is 7:0.
//
// Icarus Verilog 13.0 has no DPI.

module test_dpi_sized_formal_normalized_ranges;
  import "DPI-C" function void c_sized(input bit [3:0][1:0] y [2:1], input logic [0:5] z,
                                       input int u [1:3][2:0], output int ou [3:1]);
  import "DPI-C" function void c_open(input bit [3:0][1:0] yo []);

  bit [3:0][1:0] y [2:1];
  logic [0:5] z;
  int u [1:3][2:0];
  int ou [3:1];

  initial begin
    y[2] = 8'h9c;
    y[1] = 8'h35;
    z = 6'b100110;
    foreach (u[i, j]) u[i][j] = i * 10 + j;
    c_sized(y, z, u, ou);
    $display("ou[3] %0d ou[2] %0d ou[1] %0d", ou[3], ou[2], ou[1]);
    c_open(y);
  end
endmodule
