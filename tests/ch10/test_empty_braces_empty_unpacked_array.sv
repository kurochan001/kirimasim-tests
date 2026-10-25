/*
:name: test_empty_braces_empty_unpacked_array
:description: Empty braces { } are an unpacked array concatenation with no elements: assigned to a queue or a dynamic array, or returned from a function, they give an array of size 0 (IEEE 1800-2023 Section 10.10)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.10 7.10.4 A.8.1 A.10
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_empty_braces_empty_unpacked_array.expected
*/
// IEEE 1800-2023 §10.10 and footnote 40 of A.10 (on
// empty_unpacked_array_concatenation, A.8.1): { } is an unpacked array
// concatenation of zero items, which denotes an array value with no
// elements. An unpacked array concatenation is the source of an
// assignment-like context whose target is a fixed-size, queue or dynamic
// array.
//
// The queue q and the string queue sq start with elements and the dynamic
// array d with 3 elements; after { } is assigned to each, its size is 0, and
// elements added afterwards start at index 0. A concatenation with one item
// is assigned first as a contrast. { } is also returned from a function of
// a queue type (a return statement is an assignment-like context, 10.8),
// and assigning the result to the queue r of 3 elements makes it empty.

module test_empty_braces_empty_unpacked_array;
  typedef int int_q[$];

  int q[$] = {3, 4};
  int d[];
  string sq[$] = {"a", "b", "c"};

  function automatic int_q make_empty();
    return {};
  endfunction

  initial begin
    int_q r;
    d = new[3];
    $display("before: q=%0d d=%0d sq=%0d", q.size(), d.size(), sq.size());
    q = {7};
    $display("one item: q=%0d q[0]=%0d", q.size(), q[0]);
    q = {};
    d = {};
    sq = {};
    $display("after { }: q=%0d d=%0d sq=%0d", q.size(), d.size(), sq.size());
    q.push_back(9);
    d = {5, 6};
    $display("refilled: q=%0d q[0]=%0d d=%0d d[0]=%0d", q.size(), q[0], d.size(), d[0]);
    r = {1, 2, 3};
    $display("r before=%0d", r.size());
    r = make_empty();
    $display("r returned=%0d", r.size());
  end
endmodule
