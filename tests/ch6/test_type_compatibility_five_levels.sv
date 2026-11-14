/*
:name: test_type_compatibility_five_levels
:description: Pairs of types at each level of type compatibility, matching, equivalent, assignment compatible, cast compatible and incompatible, are told apart by type comparison, try_get on a typeless mailbox, assignment, casts and $cast; class handles, interface class handles and chandles are incompatible with other types and convert only within their own kind (IEEE 1800-2023 Sections 6.22 and 6.22.5)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.22 6.22.5 6.22.1 6.22.2 6.22.3 6.22.4 6.24.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_compatibility_five_levels.expected
*/
// IEEE 1800-2023 §6.22 sorts pairs of types into levels: matching (6.22.1),
// equivalent (6.22.2), assignment compatible (6.22.3), cast compatible
// (6.22.4), and type incompatible for the rest (6.22.5). Each level includes
// the ones before it, and the test shows for each a pair that is at that
// level and not at the one before:
// - matching: a type comparison is 1 only for matching types (6.23); byte
//   matches bit signed [7:0] but not bit signed [0:7] (6.22.1 e);
// - equivalent: bit signed [0:7] does not match byte, but it is equivalent
//   (6.22.2 c), so try_get on a typeless mailbox (15.4.6), which needs an
//   equivalent variable, takes the byte message -3;
// - assignment compatible: an enum converts to int without a cast, but the
//   types are not equivalent, so try_get of the enum message into an int is
//   negative and leaves the int unchanged;
// - cast compatible: two unpacked structures sa_t and sb_t of the same size
//   have an explicit bit-stream cast (6.24.3) but no implicit conversion, so
//   sb_t'(x) gives 1 2 while $cast called as a function, which for arguments
//   that are not singular checks assignment compatibility (6.24.2), returns 0;
// - incompatible: for singular arguments $cast checks cast compatibility and
//   returns 0, without an error and without an assignment, when the types
//   are type incompatible. A class handle, an interface class handle and a
//   chandle are incompatible with int and with each other's kinds (6.22.5),
//   while the conversions within one kind succeed: a base handle that holds a
//   derived object casts to the derived class (8.16), a class handle to an
//   interface class it implements, and a chandle to a chandle.
// The mailbox results print only their sign, which is all that the standard
// fixes.
// Oracle checks: Icarus Verilog 13.0 does not parse the interface class, and
// the 5.054 release of Verilator rejects the typeless mailbox as if its type
// parameter had no default and reports $cast between a class handle and an
// int as unsupported, so the expected output follows the cited clauses alone.

module test_type_compatibility_five_levels;
  class base_c;
  endclass
  class derived_c extends base_c;
  endclass
  interface class if_c;
  endclass
  class impl_c implements if_c;
  endclass
  typedef enum {RED, GREEN, BLUE} color_t;
  typedef struct {int a; int b;} sa_t;
  typedef struct {int a; int b;} sb_t;
  mailbox mb;
  byte by;
  bit signed [0:7] rb;
  color_t c, c2;
  int i, j;
  sa_t x;
  sb_t y, y2;
  base_c h, hb;
  derived_c d, d2;
  if_c ifh, ifh2;
  impl_c im;
  chandle ch, ch2;
  int r1, r2, r3, r4, r5, r6;

  function automatic string sign(int r);
    return r > 0 ? "positive" : (r < 0 ? "negative" : "zero");
  endfunction

  initial begin
    $display("matching: byte and bit signed [7:0] %0d, byte and bit signed [0:7] %0d",
             type(byte) == type(bit signed [7:0]), type(byte) == type(bit signed [0:7]));
    mb = new();
    by = -3;
    rb = 0;
    mb.put(by);
    r1 = mb.try_get(rb);
    $display("equivalent: try_get into bit signed [0:7] %s %0d", sign(r1), rb);
    c = BLUE;
    i = c;
    j = 0;
    mb.put(c);
    r1 = mb.try_get(j);
    r2 = mb.try_get(c2);
    $display("assignment compatible: int = color_t gives %0d, try_get into int %s %0d",
             i, sign(r1), j);
    $display("assignment compatible: try_get into color_t %s %s", sign(r2), c2.name());
    x.a = 1;
    x.b = 2;
    y = sb_t'(x);
    y2.a = 0;
    y2.b = 0;
    r1 = $cast(y2, x);
    $display("cast compatible: sb_t'(x) gives %0d %0d, $cast=%0d leaves %0d %0d",
             y.a, y.b, r1, y2.a, y2.b);
    d = new();
    h = d;
    im = new();
    ifh = im;
    i = 7;
    r1 = $cast(i, h);
    r2 = $cast(hb, i);
    r3 = $cast(i, ch);
    r4 = $cast(ch, i);
    r5 = $cast(i, ifh);
    r6 = $cast(ch, h);
    $display("incompatible: int<-class %0d, class<-int %0d, int<-chandle %0d", r1, r2, r3);
    $display("incompatible: chandle<-int %0d, int<-interface class %0d, chandle<-class %0d",
             r4, r5, r6);
    $display("incompatible: unchanged i=%0d, hb is null %0d, ch is null %0d",
             i, hb == null, ch == null);
    r1 = $cast(d2, h);
    r2 = $cast(ifh2, im);
    r3 = $cast(ch2, ch);
    $display("same kind: derived<-base %0d, interface class<-class %0d, chandle<-chandle %0d",
             r1, r2, r3);
    $display("same kind: d2 is d %0d, ifh2 is ifh %0d", d2 == d, ifh2 == ifh);
  end
endmodule
