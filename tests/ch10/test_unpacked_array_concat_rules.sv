/*
:name: test_unpacked_array_concat_rules
:description: an unpacked array concatenation mixes single elements and whole arrays, the same braces form a string or vector concatenation when the target is not an unpacked array, a brace pair inside it is a string or vector concatenation, and unpacked array concatenations can be items of an assignment pattern (IEEE 1800-2023 Sections 10.10, 10.10.1, 10.10.2, 10.10.3)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.10 10.10.1 10.10.2 10.10.3 7.10.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unpacked_array_concat_rules.expected
*/
// IEEE 1800-2023 §10.10: in an unpacked array concatenation, an item of the
// element type is one element and an unpacked array item gives all its
// elements in order; {} has no elements. §10.10.1: a typed assignment pattern
// can be an item. §10.10.2: with a target that is not an unpacked array, the
// same braces are a string or vector concatenation. §10.10.3: an unpacked
// array concatenation cannot be an item of another, so inner braces are a
// string concatenation; it can be an item of an assignment pattern, which
// builds a queue of queues (§7.10.4).

module test_unpacked_array_concat_rules;
  typedef int int3_t[3];
  typedef int iq_t[$];
  typedef string sq_t[$];

  int3_t a3 = '{1, 2, 3};
  int a11[11];
  string s, s2[2];
  byte b, b2[2];
  sq_t sq;
  iq_t qq[$];
  int empty[$] = {7};

  function automatic string show(int q[$]);
    string r = "";
    foreach (q[i]) r = {r, $sformatf(" %0d", q[i])};
    return r;
  endfunction

  initial begin
    a11 = {a3, 10, a3, int3_t'{20, 30, 40}, 50};
    $display("a11:%s", show(a11));
    s = "ab";
    s2 = {s, "cd"};
    s = {s, "cd"};
    $display("string: %s, string array: %s / %s", s, s2[0], s2[1]);
    b = {4'h3, 4'ha};
    b2 = {4'h3, 4'ha};
    $display("byte: %h, byte array: %h %h", b, b2[0], b2[1]);
    sq = '{"x", "y"};
    sq = {"w", sq, {"z", s}};
    $display("queue of strings: %0d items, last %s", sq.size(), sq[$]);
    sq = {"w", sq[1:2], sq_t'{"z", s}};
    $display("with a typed item: %0d items, last %s", sq.size(), sq[$]);
    qq = '{{1}, iq_t'{2, 3, 4}, {5, 6}};
    $display("queue of queues: sizes %0d %0d %0d, qq[1][2] = %0d", qq[0].size(), qq[1].size(),
             qq[2].size(), qq[1][2]);
    empty = {};
    $display("{}: %0d elements", empty.size());
  end
endmodule
