/*
:name: test_nested_literal_replication_members
:description: Nested structure and array literals keep dimension boundaries and named members (IEEE 1800-2023 Section 5.10)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.10 5.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nested_literal_replication_members.expected
*/
// IEEE 1800-2023 5.10 5.11: A named structure literal fixes members independent
// of declaration order; array replication repeats complete inner arrays.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_nested_literal_replication_members;
  typedef struct { int head; int tail; } pair_t;
  pair_t pairs[2];
  int rows[2][3];
  initial begin
    pairs = '{'{tail: 4, head: 9}, '{head: -2, tail: 8}};
    rows = '{2{'{3{7}}}};
    $display("pairs=%0d,%0d;%0d,%0d rows=%0d,%0d", pairs[0].head, pairs[0].tail,
             pairs[1].head, pairs[1].tail, rows[0][2], rows[1][0]);
  end
endmodule
