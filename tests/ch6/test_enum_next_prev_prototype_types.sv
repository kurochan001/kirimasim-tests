/*
:name: test_enum_next_prev_prototype_types
:description: The enum methods next() and prev() return a value of the enumerated type itself and take one int unsigned count whose default is one, so an int argument of -1 becomes 4294967295 steps (IEEE 1800-2023 Sections 6.19.5.3 and 6.19.5.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5.3 6.19.5.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_next_prev_prototype_types.expected
*/
// IEEE 1800-2023 §6.19.5.3 and §6.19.5.4 give the prototypes of next() and
// prev(): each returns the enumerated type of the variable it is called on and
// has one argument N of type int unsigned, which is 1 when it is left out.
// The test checks the three parts of these prototypes with the type c7_t of
// seven names C0 to C6 on the 2-state base bit [2:0], starting from C2:
// - the result is of type c7_t: it is assigned without a cast to variables of
//   type c7_t, which only a value of that type may be (§6.19.3), and $bits of
//   a call is 3, the width of c7_t, where an int result would give 32;
// - the default count is one: next() and next(1) give C3, prev() and prev(1)
//   give C1, while a count of 2 gives C4 and C0;
// - the count is int unsigned: the int variable minus_one holds -1, and
//   passing it converts it to 4294967295 = 7 * 613566756 + 3, so next and prev
//   move three names, wrapping at the end and at the start of the list: next
//   gives C5 and prev gives C6. A signed count of -1 cannot reach either of
//   them, since a move of one name gives C1 or C3.
// The counts are variables, so the conversion happens when the argument is
// passed at run time. Oracle check: Icarus Verilog 13.0 gives the expected
// output; the 5.054 release of Verilator rejects a count that is not a
// constant as unsupported.

module test_enum_next_prev_prototype_types;
  typedef enum bit [2:0] {C0, C1, C2, C3, C4, C5, C6} c7_t;
  c7_t c, n0, n1, n2, nm, p0, p1, p2, pm;
  int unsigned two;
  int minus_one;

  initial begin
    c = C2;
    two = 2;
    minus_one = -1;
    n0 = c.next();
    n1 = c.next(1);
    n2 = c.next(two);
    nm = c.next(minus_one);
    p0 = c.prev();
    p1 = c.prev(1);
    p2 = c.prev(two);
    pm = c.prev(minus_one);
    $display("next()=%s next(1)=%s next(2)=%s next(-1)=%s",
             n0.name(), n1.name(), n2.name(), nm.name());
    $display("prev()=%s prev(1)=%s prev(2)=%s prev(-1)=%s",
             p0.name(), p1.name(), p2.name(), pm.name());
    $display("bits: next=%0d prev=%0d", $bits(c.next()), $bits(c.prev()));
  end
endmodule
