/*
:name: test_illegal_part_select_reversed_bounds
:description: a non-indexed part-select whose first bound addresses a less significant bit than the second is illegal (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: v is declared [7:0] and the part-select v[0:3] names the less significant bit first
:expected_stderr_regex: test_illegal_part_select_reversed_bounds\.sv:25:
*/
// IEEE 1800-2023 §11.5.1: in a non-indexed part-select [msb:lsb] the first
// expression shall address a more significant bit than the second. v is
// declared [7:0], so v[3:0] is legal and v[0:3] names its bounds in the
// wrong order. Verilator 5.052 accepts the design.

module test_illegal_part_select_reversed_bounds;
  logic [7:0] v = 8'h5a;
  logic [3:0] r, q;

  initial begin
    q = v[3:0];
    r = v[0:3];   // illegal: bounds in the opposite order of the declaration
  end
endmodule
