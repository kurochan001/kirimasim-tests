/*
:name: test_array_method_index_argument
:description: The second argument of an array method names the index method of its iterator, also where an element has a member named index (IEEE 1800-2023 Section 7.12)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12 7.12.4 7.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_method_index_argument.expected
*/
// IEEE 1800-2023 §7.12: an array method can take the name of its iterator and,
// as a second argument, the name of the method that gives the index of the
// iterator (§7.12.4), which is index by default. With the name at, v.at gives
// the position of the element: find keeps 20 and 40, which equal their position
// times 10, and find_index the positions 2 and 4. The elements of recs have a
// member named index, so the second search names the index method i and
// compares the member with it.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports this construct of
// IEEE 1800-2023.

module test_array_method_index_argument;
  typedef struct {int index; int value;} rec_t;
  int q[$] = '{10, 1, 20, 3, 40};
  int r[$];
  rec_t recs[$] = '{'{5, 0}, '{1, 10}, '{2, 20}};
  rec_t found[$];
  initial begin
    r = q.find(v, at) with (v == v.at * 10);
    $display("find: %0d values, %0d and %0d", r.size(), r[0], r[1]);
    r = q.find_index(v, pos) with (v.pos > 1 && v > 5);
    $display("find_index: %0d positions, %0d and %0d", r.size(), r[0], r[1]);
    found = recs.find(e, i) with (e.index == e.i);
    $display("records: %0d found, values %0d and %0d", found.size(), found[0].value,
             found[1].value);
  end
endmodule
