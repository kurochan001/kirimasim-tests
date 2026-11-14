/*
:name: test_type_equivalence_only_by_rules
:description: Two types are equivalent only when a rule of the inductive definition makes them so: int is equivalent to a 32-bit 2-state signed packed structure or bit vector, but not to an enum based on int, two enums or two unpacked structures with the same contents are not equivalent, and try_peek and $cast show each case (IEEE 1800-2023 Section 6.22.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.22.2 6.24.2 15.4.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_equivalence_only_by_rules.expected
*/
// IEEE 1800-2023 §6.22.2 defines equivalence by a list of rules, and two
// types that no rule makes equivalent are nonequivalent. Rule a makes
// matching types equivalent, and rule c makes packed arrays, packed
// structures, packed unions and built-in integral types equivalent when they
// have the same number of bits, states and signing. No rule covers an enum
// against its base type or against another enum, or two unpacked structure
// types that are declared apart (rule b is only for anonymous types).
// try_peek on a typeless mailbox (15.4.8) returns a positive value and copies
// the message when the type of the variable is equivalent to the type of the
// message, and a negative value, leaving the variable unchanged, otherwise;
// the test prints the sign, which is all that the standard fixes. For
// unpacked structures, which are not singular, $cast called as a function
// (6.24.2) returns 1 and assigns when the types are assignment compatible,
// which for them needs equivalent types (6.22.3), and returns 0 otherwise.
// - An int message: pair_t (packed, signed, 32 2-state bits) and
//   bit signed [0:31] are equivalent to int by rule c, whatever their member
//   layout and range; int unsigned (signing) and logic signed [31:0] (states)
//   fail rule c; k_t has the base type int but is an enum, which no rule
//   relates to int.
// - A k_t message: only k_t is equivalent; l_t has the same base type and
//   values, and int is the base type, but neither is equivalent.
// - ua_t and ub_t are unpacked structures with the same member: the cast from
//   ua_t to ub_t fails, and the cast between two ua_t variables succeeds.
// Oracle checks: Icarus Verilog 13.0 does not support unpacked structures,
// and the 5.054 release of Verilator rejects the typeless mailbox as if its
// type parameter had no default, so the expected output follows the cited
// clauses alone.

module test_type_equivalence_only_by_rules;
  typedef enum {K0, K1, K2} k_t;
  typedef enum {L0, L1, L2} l_t;
  typedef struct packed signed {bit [15:0] hi; bit [15:0] lo;} pair_t;
  typedef struct {int a;} ua_t;
  typedef struct {int a;} ub_t;
  mailbox mb;
  int i;
  pair_t ps;
  bit signed [0:31] rev;
  int unsigned iu;
  logic signed [31:0] ls;
  k_t k, k2;
  l_t l;
  ua_t x, z;
  ub_t y;
  int r1, r2, r3, r4, r5;

  function automatic string sign(int r);
    return r > 0 ? "positive" : (r < 0 ? "negative" : "zero");
  endfunction

  initial begin
    mb = new();
    i = 5;
    ps = 0;
    rev = 0;
    iu = 0;
    ls = 0;
    k = K0;
    mb.put(i);
    r1 = mb.try_peek(ps);
    r2 = mb.try_peek(rev);
    r3 = mb.try_peek(iu);
    r4 = mb.try_peek(ls);
    r5 = mb.try_peek(k);
    $display("int message: pair_t %s %0d, bit signed [0:31] %s %0d", sign(r1), ps,
             sign(r2), rev);
    $display("int message: int unsigned %s %0d, logic signed [31:0] %s %0d, k_t %s %s",
             sign(r3), iu, sign(r4), ls, sign(r5), k.name());
    r1 = mb.try_get(i);
    $display("int message taken: %s, num=%0d", sign(r1), mb.num());
    k = K1;
    k2 = K0;
    l = L0;
    i = 0;
    mb.put(k);
    r1 = mb.try_peek(k2);
    r2 = mb.try_peek(l);
    r3 = mb.try_peek(i);
    $display("k_t message: k_t %s %s, l_t %s %s, int %s %0d", sign(r1), k2.name(),
             sign(r2), l.name(), sign(r3), i);
    x.a = 7;
    y.a = 0;
    z.a = 0;
    r1 = $cast(y, x);
    r2 = $cast(z, x);
    $display("unpacked: ua_t to ub_t cast=%0d y.a=%0d, ua_t to ua_t cast=%0d z.a=%0d",
             r1, y.a, r2, z.a);
  end
endmodule
