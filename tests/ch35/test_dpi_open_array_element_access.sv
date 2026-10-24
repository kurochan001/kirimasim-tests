/*
:name: test_dpi_open_array_element_access
:description: Elements of open arrays are read and written by copying packed elements to and from canonical chunks, by reading and writing scalar bit and logic elements directly, and through element pointers for int and longint elements, with SystemVerilog indices, while the whole-array pointer and size agree with each other (IEEE 1800-2023 Section 35.5.6.1, H.12.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 H.12.3 H.12.4 H.12.5 H.12.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_open_array_element_access.c
:expected_stdout: @test_dpi_open_array_element_access.expected
*/
// IEEE 1800-2023 §35.5.6.1: open array formals take the actuals' ranges.
// H.12.3: how an element is reached depends on its type: a packed bit or logic
// element is copied to or from its canonical chunks (H.12.5), a scalar bit or
// logic element is read or written as a value (H.12.6), and an element of
// another type is reached through the address that a library function
// computes (H.12.4), which the C code casts to the element type. There are
// functions for the address of the whole array, and the indices are the
// SystemVerilog indices of the actual. H.12.4: the whole-array address and
// size are 0 when the array does not have the C layout; otherwise the size is
// the number of bytes of all elements.
//
// c_packed reads each 12-bit bit element of p[3:1] and logic element of
// q[0:1] into a chunk and writes back the value plus 1; c_scalars reads the
// bit and logic elements and writes back their complement; c_others reads int
// and longint elements through their addresses and doubles them, and checks
// that the whole-array pointer, when there is one, is the address of the
// element with the lowest index and the size is three ints, and that both
// are 0 otherwise. The design prints the arrays after each call.

module test_dpi_open_array_element_access;
  import "DPI-C" function void c_packed(inout bit [11:0] p [], inout logic [11:0] q []);
  import "DPI-C" function void c_scalars(inout bit s [], inout logic l []);
  import "DPI-C" function void c_others(inout int i [], inout longint g []);

  bit [11:0] p [3:1];
  logic [11:0] q [0:1];
  bit s [0:3];
  logic l [0:3];
  int i [1:3];
  longint g [0:1];

  initial begin
    p = '{12'h123, 12'h456, 12'h789};
    q = '{12'habc, 12'h0f0};
    s = '{1'b1, 1'b0, 1'b1, 1'b1};
    l = '{1'b0, 1'b1, 1'b1, 1'b0};
    i = '{10, 20, 30};
    g = '{64'd5000000000, -64'sd7};
    c_packed(p, q);
    $display("p[3] %h p[2] %h p[1] %h q[0] %h q[1] %h", p[3], p[2], p[1], q[0], q[1]);
    c_scalars(s, l);
    $display("s %b%b%b%b l %b%b%b%b", s[0], s[1], s[2], s[3], l[0], l[1], l[2], l[3]);
    c_others(i, g);
    $display("i[1] %0d i[2] %0d i[3] %0d g[0] %0d g[1] %0d", i[1], i[2], i[3], g[0], g[1]);
  end
endmodule
