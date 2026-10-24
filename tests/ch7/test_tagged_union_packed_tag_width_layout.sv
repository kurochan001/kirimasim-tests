/*
:name: test_tagged_union_packed_tag_width_layout
:description: a packed tagged union is as wide as the fewest tag bits that code its member names plus its widest member, with the tag in the top bits, each member in the low bits, and the same layout inside a nested tagged union (IEEE 1800-2023 Section 7.3.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.2 11.9 20.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_tagged_union_packed_tag_width_layout.expected
*/
// IEEE 1800-2023 §7.3.2: the size of a packed tagged union is the number of
// tag bits plus the size of its widest member, where the tag has the minimum
// number of bits that codes all member names. The tag bits are at the most
// significant end and the bits of each member at the least significant end;
// the bits in between are undefined. Nested tagged unions get the same
// representation.
// The unions below have 2, 3, 4, 5, 8 and 9 members, which need 1, 2, 2, 3, 3
// and 4 tag bits, and $bits (§20.6.2) shows each size. The standard does not
// say which code each member name gets beyond the minimum width, so the test
// prints no tag value: it checks that different members give different top
// bits, that the top bits of one member do not depend on its value, and that a
// member value (§11.9 tagged expression) is in the low bits. The undefined
// bits are not printed. A nested union fills the low bits of out_t with
// exactly the bits it has on its own.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports tagged unions.

module test_tagged_union_packed_tag_width_layout;
  typedef union tagged packed { void N; logic [7:0] B; } u2_t;
  typedef union tagged packed { void A; logic [5:0] B; logic [2:0] C; } u3_t;
  typedef union tagged packed { logic [3:0] M0, M1, M2, M3; } u4_t;
  typedef union tagged packed { logic [3:0] M0, M1, M2, M3, M4; } u5_t;
  typedef union tagged packed { logic [1:0] M0, M1, M2, M3, M4, M5, M6, M7; } u8_t;
  typedef union tagged packed { logic [1:0] M0, M1, M2, M3, M4, M5, M6, M7, M8; } u9_t;
  typedef union tagged packed { logic [4:0] P; logic [6:0] Q; } in_t;
  typedef union tagged packed { logic [2:0] X; in_t Y; } out_t;

  u2_t v2;
  u3_t v3;
  in_t vi;
  out_t vo;
  logic [8:0] n2, b2;
  logic [7:0] a3, b3, b3z, c3, iw;
  logic [8:0] ox, oy;

  initial begin
    $display("sizes: u2=%0d u3=%0d u4=%0d u5=%0d u8=%0d u9=%0d in=%0d out=%0d",
             $bits(u2_t), $bits(u3_t), $bits(u4_t), $bits(u5_t), $bits(u8_t),
             $bits(u9_t), $bits(in_t), $bits(out_t));

    v2 = tagged N;
    n2 = v2;
    v2 = tagged B 8'hc3;
    b2 = v2;
    $display("u2: B member bits=%h, tags differ=%0d", b2[7:0], n2[8] != b2[8]);

    v3 = tagged A;
    a3 = v3;
    v3 = tagged B 6'h2d;
    b3 = v3;
    v3 = tagged B 6'h00;
    b3z = v3;
    v3 = tagged C 3'h5;
    c3 = v3;
    $display("u3: B member bits=%h, C member bits=%h", b3[5:0], c3[2:0]);
    $display("u3: tags differ A/B=%0d B/C=%0d A/C=%0d, B tag same for 2d and 00=%0d",
             a3[7:6] != b3[7:6], b3[7:6] != c3[7:6], a3[7:6] != c3[7:6],
             b3[7:6] == b3z[7:6]);

    vi = tagged Q 7'h55;
    iw = vi;
    vo = tagged Y (tagged Q 7'h55);
    oy = vo;
    vo = tagged X 3'h3;
    ox = vo;
    $display("out: Y low bits equal the inner union=%0d, Q member bits=%h",
             oy[7:0] == iw, oy[6:0]);
    $display("out: X member bits=%h, outer tags differ=%0d", ox[2:0], ox[8] != oy[8]);
  end
endmodule
