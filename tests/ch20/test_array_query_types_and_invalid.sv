/*
:name: test_array_query_types_and_invalid
:description: Array query functions accept a data type and a constant expression, an empty queue returns -1 for the right bound and increment, and an invalid dimension returns x while the dimension counts keep 0 (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_array_query_types_and_invalid.expected
*/
// IEEE 1800-2023 §20.7: the first argument may be a data type, as in
// $size(int), $dimensions(string) and $size(Word). A call with a fixed-size
// type and a constant dimension is legal in a constant expression; the
// standard's own example has $size(Word) and $size(Ram,2) return 16. For a
// queue, $left is 0 and $increment is -1; $right is -1 while the queue is
// empty and the index of the last element otherwise. An invalid first
// argument, or a dimension out of range, returns all x, while $dimensions and
// $unpacked_dimensions keep their defined 0. Icarus Verilog 13.0 rejects type
// arguments, so this test is checked against the standard only.

module test_array_query_types_and_invalid;
  typedef logic [16:1] Word;
  Word Ram[0:9];
  int q[$];
  int dyn[];
  real r;
  string s;

  localparam int LP_WORD = $size(Word);
  localparam int LP_RAM1 = $size(Ram, 1);
  localparam int LP_RAM2 = $size(Ram, 2);
  logic [LP_WORD-1:0] uses_word;

  int errors = 0;

  task automatic chk(string what, int got, int want);
    if (got === want)
      $display("ok   %s = %0d", what, got);
    else begin
      $display("BAD  %s got=%0d want=%0d", what, got, want);
      errors++;
    end
  endtask

  task automatic chkx(string what, integer got);
    if (got === 32'bx)
      $display("ok   %s = x", what);
    else begin
      $display("BAD  %s got=%0d want=x", what, got);
      errors++;
    end
  endtask

  initial begin
    // A data type is accepted as the first argument.
    chk("size(int)", $size(int), 32);
    chk("left(int)", $left(int), 31);
    chk("right(int)", $right(int), 0);
    chk("low(int)", $low(int), 0);
    chk("high(int)", $high(int), 31);
    chk("increment(int)", $increment(int), 1);
    chk("size(byte)", $size(byte), 8);
    chk("size(longint)", $size(longint), 64);
    chk("size(Word)", $size(Word), 16);
    chk("dimensions(string)", $dimensions(string), 1);
    chk("dimensions(int)", $dimensions(int), 1);
    chk("dimensions(real)", $dimensions(real), 0);
    chk("unpacked(int)", $unpacked_dimensions(int), 0);

    // The standard's array example: unpacked [0:9], packed [16:1].
    chk("size(Ram,1)", $size(Ram, 1), 10);
    chk("left(Ram,1)", $left(Ram, 1), 0);
    chk("right(Ram,1)", $right(Ram, 1), 9);
    chk("low(Ram,1)", $low(Ram, 1), 0);
    chk("high(Ram,1)", $high(Ram, 1), 9);
    chk("increment(Ram,1)", $increment(Ram, 1), -1);
    chk("size(Ram,2)", $size(Ram, 2), 16);
    chk("left(Ram,2)", $left(Ram, 2), 16);
    chk("right(Ram,2)", $right(Ram, 2), 1);
    chk("low(Ram,2)", $low(Ram, 2), 1);
    chk("high(Ram,2)", $high(Ram, 2), 16);
    chk("increment(Ram,2)", $increment(Ram, 2), 1);
    chk("size(Ram)", $size(Ram), 10);
    chk("left(Ram)", $left(Ram), 0);
    chk("low(Ram)", $low(Ram), 0);
    chk("high(Ram)", $high(Ram), 9);
    chk("dimensions(Ram)", $dimensions(Ram), 2);
    chk("unpacked(Ram)", $unpacked_dimensions(Ram), 1);

    // A fixed-size type and constant dimension are legal in a constant.
    chk("constant size(Word)", LP_WORD, 16);
    chk("constant size(Ram,1)", LP_RAM1, 10);
    chk("constant size(Ram,2)", LP_RAM2, 16);
    chk("bits of uses_word", $bits(uses_word), 16);

    // Queue: left 0 and increment -1, right -1 only while empty.
    chk("size(q)", $size(q), 0);
    chk("left(q)", $left(q), 0);
    chk("right(q) empty", $right(q), -1);
    chk("increment(q)", $increment(q), -1);
    q.push_back(7);
    chk("size(q) after push", $size(q), 1);
    chk("left(q) after push", $left(q), 0);
    chk("right(q) after push", $right(q), 0);
    chk("increment(q) after push", $increment(q), -1);

    // An empty dynamic array also has left 0, increment -1 and right -1.
    chk("size(dyn)", $size(dyn), 0);
    chk("left(dyn)", $left(dyn), 0);
    chk("right(dyn) empty", $right(dyn), -1);
    chk("increment(dyn)", $increment(dyn), -1);

    // Invalid first argument or out-of-range dimension returns all x.
    chkx("left(real)", $left(r));
    chkx("size(real,1)", $size(r, 1));
    chkx("left(int,2)", $left(int, 2));
    chkx("size(string,2)", $size(s, 2));
    chkx("left(logic[7:0],2)", $left(logic [7:0], 2));

    // The dimension counts keep their defined zero.
    chk("dimensions(real)", $dimensions(r), 0);
    chk("unpacked(real)", $unpacked_dimensions(r), 0);

    if (errors == 0) $display("TEST PASSED");
    else $display("TEST FAILED: %0d check(s) failed", errors);
  end
endmodule
