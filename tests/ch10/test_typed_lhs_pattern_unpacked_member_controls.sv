/*
:name: test_typed_lhs_pattern_unpacked_member_controls
:description: A typed LHS pattern assigns matching unpacked members by position (IEEE 1800-2023 Section 10.9)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.9
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typed_lhs_pattern_unpacked_member_controls.expected
*/
// IEEE 1800-2023 10.9 B008/B015 requires positional LHS patterns,
// bit-stream members, compatible types and equal bit counts.
// Expected diagnostics are derived from these requirements, not a tool.

module test_typed_lhs_pattern_unpacked_member_controls;
  typedef int row_t[2];
  typedef row_t matrix_t[2];
  matrix_t src = '{'{3, 5}, '{7, 9}};
  row_t first, second;
  initial begin
    matrix_t'{first, second} = src;
    $display("typed %0d %0d %0d %0d", first[0], first[1], second[0], second[1]);
    src = '{'{11, 13}, '{17, 19}};
    matrix_t'{second, first} = src;
    $display("reversed %0d %0d %0d %0d", first[0], first[1], second[0], second[1]);
  end
endmodule

// Fixed-tool note: Icarus Verilog 13.0 also rejects legal LHS patterns;
// an unsupported diagnostic is not an oracle for these cases.
