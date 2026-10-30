/*
:name: test_cg_four_state_literal_wildcard_enum
:description: An explicit integral bin with x or z matches those bits literally by case equality, a wildcard bin treats x, z and ? as all 0/1 possibilities but excludes sampled values with x or z, and arithmetic and ranges on enumeration values use the base type of the enumeration (IEEE 1800-2023 Sections 19.5.4, 19.5.7)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.4 19.5.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_cg_four_state_literal_wildcard_enum.expected
*/
// IEEE 1800-2023 §19.5.4: a bin value with x or z increments the bin only
// when the sampled value has the same x or z in the same bit positions, as
// with ===. A wildcard bin instead treats every x, z or ? of the bin value as
// a choice of 0 or 1, and a sampled value containing x or z is excluded.
// §19.5.7: enumeration values in bin and point expressions are first taken in
// an expression context, where their type is the base type of the
// enumeration, so E1+E2 is the base-type value 3 and [E4:E6] is the range 4
// to 6. The test samples each point and prints get_inst_coverage(c,t).
//
// v is sampled with 1x0z, 1x00, 1z0z and 1100. Only the first matches the
// literal bin; the wildcard bin matches only the last, because a sampled
// value with x or z is excluded. w goes 0x then 1z, which matches the literal
// transition, and then 0x then 1x, which does not. e is E3 then E5. The
// literals 4'b0x and 4'b1z are padded on the left with zeros (5.7.1), so %b
// prints w as 000x and 001z.
//
// The standard is not consistent about the literal bins: §19.5.4 counts an x
// or z bin value with ===, as above, while rule 3 of §19.5.7 asks for a
// warning for a non-wildcard bin value with x or z bits and takes that value
// out of the bin. The test follows §19.5.4; under §19.5.7 the bins lit.xz and
// tr.xz would have no values.

module test_cg_four_state_literal_wildcard_enum;
  logic [3:0] v, w;
  typedef enum logic [2:0] {E0 = 0, E1 = 1, E2 = 2, E3 = 3,
                            E4 = 4, E5 = 5, E6 = 6, E7 = 7} e_t;
  e_t e;

  covergroup cg;
    lit: coverpoint v { bins xz = {4'b1x0z}; }
    wild: coverpoint v { wildcard bins wxz = {4'b1x0z}; }
    tr: coverpoint w { bins xz = (4'b0x => 4'b1z); }
    en: coverpoint e { bins add = {E1 + E2}; bins rng = {[E4:E6]}; }
  endgroup

  cg g = new;

  task automatic put(logic [3:0] vv, logic [3:0] ww, e_t ee);
    int c[4], t[4];
    v = vv;
    w = ww;
    e = ee;
    g.sample();
    void'(g.lit.get_inst_coverage(c[0], t[0]));
    void'(g.wild.get_inst_coverage(c[1], t[1]));
    void'(g.tr.get_inst_coverage(c[2], t[2]));
    void'(g.en.get_inst_coverage(c[3], t[3]));
    $display("v=%b w=%b: lit %0d/%0d wild %0d/%0d tr %0d/%0d en %0d/%0d", vv, ww,
             c[0], t[0], c[1], t[1], c[2], t[2], c[3], t[3]);
  endtask

  initial begin
    put(4'b1x0z, 4'b0000, E0);
    put(4'b1x00, 4'b0x, E0);
    put(4'b1z0z, 4'b1z, E0);
    put(4'b1100, 4'b0x, E3);
    put(4'b1100, 4'b1x, E5);
  end
endmodule
