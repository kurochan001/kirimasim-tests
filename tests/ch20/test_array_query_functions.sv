/*
:name: test_array_query_functions
:description: Array query functions number dimensions from the slowest varying one and return the bounds, increment, size and dimension counts of packed, unpacked, dynamic and predefined-width data objects (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_query_functions.expected
*/
// IEEE 1800-2023 §20.7: $left, $right, $low, $high, $increment and $size
// take an array expression and an optional dimension that defaults to 1.
// Dimensions are numbered from the slowest varying as 1; the typedef
// packed_reg below expands to the same dimensions as the inline declaration
// of n. A fixed dimension with left >= right has increment 1 and the other
// direction has -1; a dynamic array has increment -1, left 0, and right -1
// when empty. A predefined-width integer is one packed [width-1:0] dimension.
// $dimensions counts packed and unpacked dimensions and is 1 for string and
// simple bit vectors, and 0 for the other types in its domain;
// $unpacked_dimensions counts only unpacked dimensions. A real, shortreal
// or event is outside the domain of both (§20.7), so neither is passed to
// them. An empty queue and an invalid dimension are checked in
// test_array_query_types_and_invalid, because Icarus Verilog 13.0 returns 0
// for an empty queue's right bound and increment instead of -1, and counts a
// dynamic array of int as 0 dimensions instead of 2.

module test_array_query_functions;
  typedef logic [3:0][2:1] packed_reg;

  logic [3:0][2:1] n [1:5][2:8];
  packed_reg pn [1:5][2:8];
  packed_reg pv;
  int dyn[];
  int ua[3];
  int iv;
  byte bv;
  longint lv;
  integer gv;
  string s;
  logic [7:0] v;

  int errors = 0;

  task automatic chk(string what, int got, int want);
    if (got === want)
      $display("ok   %s = %0d", what, got);
    else begin
      $display("BAD  %s got=%0d want=%0d", what, got, want);
      errors++;
    end
  endtask

  initial begin
    // Dimension numbering after expanding the typedef, slowest first.
    chk("size(n,1)", $size(n, 1), 5);
    chk("size(n,2)", $size(n, 2), 7);
    chk("size(n,3)", $size(n, 3), 4);
    chk("size(n,4)", $size(n, 4), 2);
    chk("size(pn,1)", $size(pn, 1), 5);
    chk("size(pn,2)", $size(pn, 2), 7);
    chk("size(pn,3)", $size(pn, 3), 4);
    chk("size(pn,4)", $size(pn, 4), 2);

    // Bounds and increment, both directions.
    chk("left(n,1)", $left(n, 1), 1);
    chk("right(n,1)", $right(n, 1), 5);
    chk("increment(n,1)", $increment(n, 1), -1);
    chk("low(n,1)", $low(n, 1), 1);
    chk("high(n,1)", $high(n, 1), 5);
    chk("left(n,3)", $left(n, 3), 3);
    chk("right(n,3)", $right(n, 3), 0);
    chk("increment(n,3)", $increment(n, 3), 1);
    chk("low(n,3)", $low(n, 3), 0);
    chk("high(n,3)", $high(n, 3), 3);
    chk("increment(n,4)", $increment(n, 4), 1);

    // Default dimension is 1.
    chk("size(n)", $size(n), 5);
    chk("left(n)", $left(n), 1);
    chk("size(pv)", $size(pv), 4);
    chk("size(pv,2)", $size(pv, 2), 2);

    // Predefined-width integers are one packed [width-1:0] dimension.
    chk("size(iv)", $size(iv), 32);
    chk("left(iv)", $left(iv), 31);
    chk("right(iv)", $right(iv), 0);
    chk("increment(iv)", $increment(iv), 1);
    chk("size(bv)", $size(bv), 8);
    chk("left(bv)", $left(bv), 7);
    chk("size(lv)", $size(lv), 64);
    chk("left(gv)", $left(gv), 31);

    // An empty dynamic array: left 0, increment -1, right -1.
    chk("size(dyn)", $size(dyn), 0);
    chk("left(dyn)", $left(dyn), 0);
    chk("right(dyn)", $right(dyn), -1);
    chk("increment(dyn)", $increment(dyn), -1);

    // Dimension counts.
    chk("dimensions(n)", $dimensions(n), 4);
    chk("dimensions(pv)", $dimensions(pv), 2);
    chk("dimensions(ua)", $dimensions(ua), 2);
    chk("dimensions(dyn)", $dimensions(dyn), 2);
    chk("dimensions(v)", $dimensions(v), 1);
    chk("dimensions(s)", $dimensions(s), 1);
    chk("dimensions(iv)", $dimensions(iv), 1);
    chk("unpacked(n)", $unpacked_dimensions(n), 2);
    chk("unpacked(pv)", $unpacked_dimensions(pv), 0);
    chk("unpacked(ua)", $unpacked_dimensions(ua), 1);
    chk("unpacked(dyn)", $unpacked_dimensions(dyn), 1);
    chk("unpacked(iv)", $unpacked_dimensions(iv), 0);

    if (errors == 0) $display("TEST PASSED");
    else $display("TEST FAILED: %0d check(s) failed", errors);
  end
endmodule
