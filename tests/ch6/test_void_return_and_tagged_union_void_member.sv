/*
:name: test_void_return_and_tagged_union_void_member
:description: void functions return no data and a tagged union void member carries only its tag
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.13 7.3.2 11.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_void_return_and_tagged_union_void_member.expected
*/
// IEEE 1800-2023 6.13: void represents nonexistent data. A function declared
// with the void return type produces no value, and a tagged union may have a
// void member whose value is carried by the tag alone (7.3.2, 11.9). The test
// writes through an output argument of a void function, builds the void member
// of a tagged union, and reads the tag and the payload of both tags through
// pattern matching.

typedef union tagged {
  void Invalid;
  int Valid;
} vint_t;

module test_void_return_and_tagged_union_void_member;
  vint_t v;
  int r;
  int calls;

  function automatic void set(output int dst, input int src);
    dst = src;
  endfunction

  initial begin
    calls = 0;
    set(r, 42);
    calls++;
    $display("r=%0d", r);
    v = tagged Invalid;
    calls++;
    if (v matches tagged Invalid) $display("tag=invalid");
    v = tagged Valid (7);
    calls++;
    if (v matches tagged Valid .n) $display("tag=valid n=%0d", n);
    $display("calls=%0d", calls);
  end
endmodule
