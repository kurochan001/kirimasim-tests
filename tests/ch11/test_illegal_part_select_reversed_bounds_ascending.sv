/*
:name: test_illegal_part_select_reversed_bounds_ascending
:description: in a non-indexed part-select of a vector declared with an ascending range, the first bound has to address the more significant bit, which is the lower index (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: u is declared [0:7], where bit 0 is the most significant, and the part-select u[3:0] names the less significant bit 3 first
:expected_stderr_regex: test_illegal_part_select_reversed_bounds_ascending\.sv:28:
*/
// IEEE 1800-2023 §11.5.1: the first expression of a non-indexed part-select
// shall address a more significant bit than the second. Which bit is more
// significant follows the declared range: in u, declared [0:7], bit 0 is the
// most significant bit. u[0:3] therefore names its bounds in the right order
// and is legal, and u[3:0] names them in the wrong order. A vector declared
// [7:0] is the other way round, which another test covers.
// The 5.054 release of Verilator accepts the design with warnings.

module test_illegal_part_select_reversed_bounds_ascending;
  logic [0:7] u = 8'h5a;
  logic [3:0] a, b;

  initial begin
    a = u[0:3];
    b = u[3:0];   // illegal: bounds in the opposite order of the declaration
  end
endmodule
