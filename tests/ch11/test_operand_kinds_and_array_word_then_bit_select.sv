/*
:name: test_operand_kinds_and_array_word_then_bit_select
:description: whole nets, variables and parameters, bit-selects and part-selects of vectors, packed arrays, packed structures and parameters, unpacked array elements, nested concatenations and function calls are operands, and an array element is addressed with one index per dimension before a bit-select or part-select (IEEE 1800-2023 Section 11.5)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5 11.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operand_kinds_and_array_word_then_bit_select.expected
*/
// IEEE 1800-2023 §11.5: the name of a net, variable or parameter used as an
// operand stands for all of its bits; a bit-select or part-select of a vector
// net or variable, a packed array, a packed structure or a parameter gives
// one bit or adjacent bits; an unpacked array element, a concatenation
// (also nested) and a function call are operands too. §11.5.2: an element of
// a multidimensional array is addressed with one index expression for each
// dimension, and the type of what is addressed follows the declaration; bit-
// and part-selects of an element are applied after its word is selected.
// The 12-bit operands are used in 16-bit sums, so all 12 bits show in the
// result (f02, abd, 124). The selects pick bits of different values in each
// kind of object. m2 is [0:2][0:3] of bytes: m2[1][2] is one byte, m2[1] a
// row of four bytes, and m2[1][2][7:4] and m2[1][2][0] select inside the
// byte; w3 has three unpacked dimensions of single bits. pm has a packed
// dimension of bytes, so pm[1][2] is a byte and pm[1][2][3] a bit of it.
// Icarus Verilog 13.0 rejects the assignment of the row m2[i] to an array of
// four bytes.

module test_operand_kinds_and_array_word_then_bit_select;
  parameter logic [11:0] P = 12'h123;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } ps_t;
  wire [11:0] w = 12'habc;
  logic [11:0] v = 12'hf01;
  logic [1:0][3:0] pa = 8'h96;
  ps_t ps = 8'h3c;
  logic [7:0] mem [0:3] = '{8'h10, 8'h20, 8'h30, 8'h40};
  logic [7:0] m2 [0:2][0:3];
  logic w3 [0:1][0:1][0:3];
  logic [3:0][7:0] pm [0:1];
  logic [7:0] row [0:3];
  logic [15:0] r16;
  int i = 1, j = 2;

  function automatic int twice(int x);
    return 2 * x;
  endfunction

  initial begin
    foreach (m2[a, b]) m2[a][b] = 8'(16 * a + b + 8'h81);
    foreach (w3[a, b, c]) w3[a][b][c] = (a + b + c) % 2;
    pm[0] = 32'h0102_0304;
    pm[1] = 32'ha1b2_c3d4;
    #1;
    r16 = v + 16'h1;
    $write("whole: %h", r16);
    r16 = w + 16'h1;
    $write(" %h", r16);
    r16 = P + 16'h1;
    $display(" %h", r16);
    $display("selects: %b %h %b %h %b %h %b %h", w[11], w[7:4], pa[1][2], pa[0], ps.lo[1],
             ps[7:4], P[8], P[3:0]);
    $display("element, concatenation, call: %h %h %0d", mem[2] + 8'h1,
             {4'h1, {4'h2, 4'h3}} + 12'h001, twice(i + j) + 1);
    row = m2[i];
    $display("m2[1][2]=%h m2[i][j]=%h row=%h %h %h %h", m2[1][2], m2[i][j], row[0], row[1],
             row[2], row[3]);
    $display("word then bits: %h %b, w3: %b %b", m2[1][2][7:4], m2[1][2][0], w3[1][0][3],
             w3[1][1][3]);
    $display("packed dimension: %h %b", pm[1][2], pm[1][2][3]);
  end
endmodule
