/*
:name: test_singular_and_aggregate_value_copy
:description: Packed singular values and unpacked aggregate values copy independently into subroutines (IEEE 1800-2023 Section 6.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.4 7.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_singular_and_aggregate_value_copy.expected
*/
// IEEE 1800-2023 6.4 7.7: An unpacked array is an aggregate copied by value,
// while a packed vector is singular; updates to either formal do not change its
// actual.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_singular_and_aggregate_value_copy;
  int a[2] = '{3, 5};
  bit [7:0] packed_value = 8'hab;
  task automatic alter(input int values[2], input bit [7:0] scalar);
    values[0] = 99; scalar[7:4] = 0;
    $display("local=%0d,%0d packed=%h", values[0], values[1], scalar);
  endtask
  initial begin
    alter(a, packed_value);
    $display("actual=%0d,%0d packed=%h", a[0], a[1], packed_value);
  end
endmodule
