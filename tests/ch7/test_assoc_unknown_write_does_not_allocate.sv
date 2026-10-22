/*
:name: test_assoc_unknown_write_does_not_allocate
:description: Writing through an unknown associative key neither creates an element nor corrupts a known entry (IEEE 1800-2023 Section 7.8.6)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.6 7.8.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_assoc_unknown_write_does_not_allocate.expected
*/
// IEEE 1800-2023 7.8.6 7.8.4: An invalid four-state key has no storage entry. A
// known key whose low bits resemble it must retain its previous value.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release is a two-state engine and is not used as the oracle here.

module test_assoc_unknown_write_does_not_allocate;
  int values[logic [3:0]];
  logic [3:0] key_value;
  initial begin
    values[4'b0011] = 17;
    key_value = 4'bx011; values[key_value] = 99;
    key_value = 4'bz011; values[key_value] = 88;
    $display("size=%0d retained=%0d", values.num(), values[4'b0011]);
  end
endmodule
