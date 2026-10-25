/*
:name: test_packed_struct_union_dimensions_and_rand_member
:description: A packed dimension with the struct keyword needs the packed keyword, and with the union keyword needs the packed and/or soft keyword; the packed array of packed structs and the packed array of packed unions have 12 bits each, a void member is used in a tagged union, and a rand member of an unpacked struct is randomized (IEEE 1800-2023 Sections 7.3.1 and 7.3.2 and footnotes 17 and 20 of A.10)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.1 7.3.2 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_struct_union_dimensions_and_rand_member.expected
*/
// IEEE 1800-2023 footnote 17 of A.10: a packed dimension with struct needs
// the packed keyword, and one with union needs soft and/or packed. §7.3.1:
// the members of a packed union share the same bits, and a packed dimension
// after the type makes an array of the type. Footnote 20 of A.10: a void
// member is allowed only in a tagged union, and a rand qualifier only in an
// unpacked structure. §7.3.2: a tagged union member with void has no value.
//
// sp is a two-element packed array of a packed struct of 4 + 2 bits, so it is
// 12 bits: sp[0] is 6'b101001 and sp[1] is 6'b010110, and sp is 12'h5A9. up is
// a two-element packed array of a packed union of 6 bits, so it is 12 bits:
// up[0] is 6'h2A and up[1] is 6'h15, and up is 12'h56A. tu = tagged None takes
// the void member, so tu matches None. Randomizing the unpacked struct us with
// us.ra == 3 returns 1 and gives ra the value 3.
//
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports tagged unions, and
// neither supports every declaration here, so this expected output follows
// the standard.

`timescale 1ns/1ns

module test_packed_struct_union_dimensions_and_rand_member;
  struct packed { logic [3:0] a; logic [1:0] b; } [1:0] sp;
  union packed { logic [5:0] all; logic [2:0] part; } [1:0] up;
  typedef union tagged { void None; int Some; } tu_t;
  tu_t tu;
  struct { rand int ra; } us;
  int ok;

  initial begin
    sp[0].a = 4'hA;
    sp[0].b = 2'b01;
    sp[1].a = 4'h5;
    sp[1].b = 2'b10;
    up[0].all = 6'h2A;
    up[1].all = 6'h15;
    tu = tagged None;
    ok = std::randomize(us) with { us.ra == 3; };
    $display("packed %0d %0d %h %h", $bits(sp), $bits(up), sp, up);
    $display("tag %0d rand %0d %0d", tu matches tagged None, ok, us.ra);
  end
endmodule
