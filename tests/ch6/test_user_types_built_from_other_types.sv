/*
:name: test_user_types_built_from_other_types
:description: User-defined types are built from other user-defined types (a packed array of a 4-bit type, a packed structure of both, an unpacked array of the structure) and declare objects whose sizes and parts follow the types they are built from (IEEE 1800-2023 Section 6.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.2 6.18 7.2.1 7.4.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_user_types_built_from_other_types.expected
*/
// IEEE 1800-2023 §6.2: data types can declare data objects or define
// user-defined data types that are built from other data types; §6.18:
// typedef names such a type.
// - nib_t is logic [3:0];
// - two_nib_t is a packed array of two nib_t (§7.4.1): 8 bits, whose element
//   [1] is the upper nibble;
// - rec_t is a packed structure (§7.2.1) of a nib_t hi and a two_nib_t
//   rest: 12 bits, hi in the upper four;
// - rec_pair_t is an unpacked array of two rec_t: 24 bits.
// The objects t, r and rp of these types are assigned 8'hA5, 12'h3C7 and
// the two elements 12'h3C7 and 12'hF12, and their parts are printed:
// t[1] = a and t[0] = 5; r.hi = 3, r.rest[1] = c and r.rest[0] = 7; rp[1]
// has hi = f and rest = 12. The element of rp has the 12 bits of rec_t and
// an element of its member rest has the 4 bits of nib_t.
// Icarus Verilog 13.0 stops with an internal assertion failure
// (elab_expr.cc) at the member selects of the elements of rp.

typedef logic [3:0] nib_t;
typedef nib_t [1:0] two_nib_t;
typedef struct packed {
  nib_t hi;
  two_nib_t rest;
} rec_t;
typedef rec_t rec_pair_t [2];

module test_user_types_built_from_other_types;
  two_nib_t t;
  rec_t r;
  rec_pair_t rp;

  initial begin
    t = 8'hA5;
    r = 12'h3C7;
    rp[0] = r;
    rp[1] = 12'hF12;
    $display("bits: two_nib_t=%0d rec_t=%0d rec_pair_t=%0d", $bits(two_nib_t), $bits(rec_t),
             $bits(rec_pair_t));
    $display("t: [1]=%h [0]=%h", t[1], t[0]);
    $display("r: hi=%h rest[1]=%h rest[0]=%h", r.hi, r.rest[1], r.rest[0]);
    $display("rp: [0].hi=%h [1].hi=%h [1].rest=%h", rp[0].hi, rp[1].hi, rp[1].rest);
    $display("parts: bits(rp[0])=%0d bits(rp[1].rest[0])=%0d", $bits(rp[0]),
             $bits(rp[1].rest[0]));
  end
endmodule
