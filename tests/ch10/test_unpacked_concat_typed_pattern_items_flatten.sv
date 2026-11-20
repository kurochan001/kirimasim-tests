/*
:name: test_unpacked_concat_typed_pattern_items_flatten
:description: A typed assignment pattern of an unpacked array type is a legal item of an unpacked array concatenation and gives its elements in order, and an unpacked array concatenation can be a non-default item of an assignment pattern, where it forms one element of the target (IEEE 1800-2023 Section 10.10.3)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.10.3 10.10
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unpacked_concat_typed_pattern_items_flatten.expected
*/
// IEEE 1800-2023 §10.10.3: an item of an unpacked array concatenation needs
// a self-determined type, so a bare unpacked array concatenation cannot be
// one, but a typed assignment pattern such as qi_t'{9, 8} has one: an
// unpacked array type. §10.10: such an item gives as many elements as it
// has, in its own left-to-right order, and an item of the element type
// gives one. §10.10.3: the items of an assignment pattern other than
// default: are in an assignment-like context, so each of them may be an
// unpacked array concatenation, which then forms a whole element of the
// target.
// q gets 7, the two elements 9 and 8 of a typed pattern, the two elements
// of the fixed-size array fixed2 and the one element of another typed
// pattern: six elements. s gets a string, the two strings of a typed
// pattern of qs_t and the first string again: four. rows, an array of two
// queues, gets the concatenations {4, 5, 6} and {q[0], 11} as its two
// elements. The test prints the sizes and the elements one by one.
// Icarus Verilog 13.0 does not parse the typed patterns.

module test_unpacked_concat_typed_pattern_items_flatten;
  typedef int qi_t[$];
  typedef string qs_t[$];
  int fixed2[2] = '{20, 21};
  qi_t q;
  qi_t rows[2];
  qs_t s;
  string s1 = "p", s2 = "r";

  function automatic string ints(qi_t x);
    string t = "";
    foreach (x[i]) t = {t, $sformatf(" %0d", x[i])};
    return t;
  endfunction

  initial begin
    q = {7, qi_t'{9, 8}, fixed2, qi_t'{10}};
    $display("q size=%0d:%s", q.size(), ints(q));
    s = {s1, qs_t'{"m", s2}, s1};
    $display("s size=%0d: %s %s %s %s", s.size(), s[0], s[1], s[2], s[3]);
    rows = '{{4, 5, 6}, {q[0], 11}};
    $display("rows[0] size=%0d:%s", rows[0].size(), ints(rows[0]));
    $display("rows[1] size=%0d:%s", rows[1].size(), ints(rows[1]));
  end
endmodule
