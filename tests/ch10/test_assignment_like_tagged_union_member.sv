/*
:name: test_assignment_like_tagged_union_member
:description: the member value of a tagged union expression is in an assignment-like context, so an assignment pattern there takes the type of the structure member and braces there are an unpacked array concatenation of the type of an array or queue member (IEEE 1800-2023 Section 10.8)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.8 10.9 10.10 11.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_like_tagged_union_member.expected
*/
// IEEE 1800-2023 §10.8: a tagged union expression is an assignment-like
// context. §11.9: after tagged and the member name comes a primary for the
// member value, which shall have the type of that member. So an assignment
// pattern without a type there takes the type of the member (§10.9), and
// braces for a member of an unpacked array type are an unpacked array
// concatenation (§10.10).
// item_t is a tagged union (unpacked) with a packed structure member Pair, a
// fixed-size unpacked array member Trio, a queue member List (dynamic types
// are allowed in tagged unions, §7.3.2) and an int member Num. Each tagged
// expression is assigned to a variable of type item_t or passed to a
// function input of that type, which gives the expression its type (§11.9).
//   - tagged Pair '{three, four}: each int goes to one 8-bit member, hi = 3
//     and lo = 4; as a vector concatenation it would be 64 bits cut to 16,
//     with hi = 0.
//   - tagged Trio and tagged List with braces: each item becomes one element;
//     List gets 2 elements and then, from a function argument, 4.
// The members are read with the tag that was set (§11.9).
// Neither Icarus Verilog 13.0 nor the 5.054 release of the Verilator tool
// supports tagged unions, so the expected output follows the clauses alone.

typedef struct packed {
  logic [7:0] hi;
  logic [7:0] lo;
} pair_t;

typedef union tagged {
  pair_t Pair;
  logic [7:0] Trio [3];
  logic [7:0] List [$];
  int Num;
} item_t;

module test_assignment_like_tagged_union_member;
  int three = 3, four = 4;
  item_t item;

  function automatic int list_sum(item_t v);
    int s = 0;
    for (int k = 0; k < v.List.size(); k++) s += v.List[k];
    return v.List.size() * 1000 + s;
  endfunction

  initial begin
    item = tagged Pair '{three, four};
    $display("Pair: hi=%0d lo=%0d", item.Pair.hi, item.Pair.lo);
    item = tagged Trio {8'd5, 8'd6, 8'd7};
    $display("Trio: %0d %0d %0d", item.Trio[0], item.Trio[1], item.Trio[2]);
    item = tagged List {8'd8, 8'd9};
    $display("List: size=%0d %0d %0d", item.List.size(), item.List[0], item.List[1]);
    item = tagged Num (three * four);
    $display("Num: %0d", item.Num);
    $display("argument: %0d", list_sum(tagged List {8'd10, 8'd20, 8'd30, 8'd40}));
  end
endmodule
