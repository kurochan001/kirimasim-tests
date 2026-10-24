/*
:name: test_dpi_packed_struct_union_formals
:description: Packed structs, packed unions and multidimensional packed arrays of bit and logic, declared through typedef or directly, are passed to and from C as one-dimensional packed arrays in the canonical form (IEEE 1800-2023 Section 35.5.6)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.7.4 H.7.5 H.7.7 6.22.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_packed_struct_union_formals.c
:expected_stdout: @test_dpi_packed_struct_union_formals.expected
*/
// IEEE 1800-2023 §35.5.6: packed arrays, structs and unions of bit and logic
// are permitted formal argument types, also when named by a typedef, and C
// sees every packed type as a one-dimensional packed array, whatever its
// declaration. H.7.4, H.7.5: a packed struct or union is handled as the
// packed array of the same width (6.22.2), and several packed dimensions are
// linearized, the first declared member or the leftmost dimension holding the
// most significant bits; H.7.7: a 2-state value is an svBitVecVal word and a
// 4-state one an svLogicVecVal. The C code returns the low 16 bits of a
// 16-bit struct {4'h1, 12'h234}, of a union holding 16'h5678, of a bit
// [1:0][7:0] holding {8'h9a, 8'hbc} and the low 8 bits of a logic [1:0][3:0]
// struct with members 4'hd and 4'he; it writes 16'habcd into an output struct,
// whose members then hold 4'ha and 12'hbcd.

module test_dpi_packed_struct_union_formals;
  typedef struct packed {
    bit [3:0] hi;
    bit [11:0] lo;
  } pair_t;

  typedef union packed {
    bit [15:0] w;
    pair_t p;
  } word_u;

  typedef struct packed {
    logic [3:0] a;
    logic [3:0] b;
  } nibbles_t;

  import "DPI-C" function int dpi_low16_pair(input pair_t v);
  import "DPI-C" function int dpi_low16_union(input word_u v);
  import "DPI-C" function int dpi_low16_2d(input bit [1:0][7:0] v);
  import "DPI-C" function int dpi_low8_logic(input nibbles_t v);
  import "DPI-C" function void dpi_make_pair(output pair_t v);

  initial begin
    pair_t p;
    word_u u;
    bit [1:0][7:0] m;
    nibbles_t n;
    p.hi = 4'h1;
    p.lo = 12'h234;
    u.w = 16'h5678;
    m[1] = 8'h9a;
    m[0] = 8'hbc;
    n.a = 4'hd;
    n.b = 4'he;
    $display("struct: %h", dpi_low16_pair(p));
    $display("union: %h", dpi_low16_union(u));
    $display("two packed dimensions: %h", dpi_low16_2d(m));
    $display("logic struct: %h", dpi_low8_logic(n));
    dpi_make_pair(p);
    $display("output struct: hi=%h lo=%h", p.hi, p.lo);
  end
endmodule
