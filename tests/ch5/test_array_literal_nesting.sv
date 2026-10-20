/*
:name: test_array_literal_nesting
:description: Array literals nest one level of braces per dimension, a replication acts within one dimension and can be nested, and a literal gets its type from a cast or from the assignment, with index and default keys (IEEE 1800-2023 Section 5.11)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.11 10.9.1 10.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_literal_nesting.expected
*/
// IEEE 1800-2023 §5.11: the braces of an array literal nest as deeply as the
// array has dimensions. A replication works within one dimension and can be
// nested; the braces of its operand are dropped, so {2{7, 8}} gives four
// elements of a row. A literal has a type, from a cast (here as the argument
// of a function) or from the assignment it is in (10.8), and it can use index
// and default keys (10.9.1).

module test_array_literal_nesting;
  typedef byte trio_t [0:2];

  int grid [0:1][0:3] = '{'{1, 2, 3, 4}, '{2{7, 8}}};
  int cube [0:1][0:1][0:1] = '{2{'{2{'{5, 6}}}}};
  trio_t keyed = '{1: 9, default: -1};

  function automatic int total(trio_t t);
    return t[0] + t[1] + t[2];
  endfunction

  initial begin
    $display("grid: %0d %0d %0d %0d / %0d %0d %0d %0d", grid[0][0], grid[0][1],
             grid[0][2], grid[0][3], grid[1][0], grid[1][1], grid[1][2], grid[1][3]);
    $display("cube: %0d %0d %0d", cube[0][0][1], cube[1][1][0], cube[1][0][1]);
    $display("keyed: %0d %0d %0d", keyed[0], keyed[1], keyed[2]);
    $display("cast literal total: %0d", total(trio_t'{10, 20, 30}));
  end
endmodule
