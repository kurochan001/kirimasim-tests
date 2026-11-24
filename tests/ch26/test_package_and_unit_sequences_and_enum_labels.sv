/*
:name: test_package_and_unit_sequences_and_enum_labels
:description: Package and compilation unit sequences and enum labels can be used side by side
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 3.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_and_unit_sequences_and_enum_labels.expected
*/
`timescale 1ns/1ns
typedef enum int {START_VALUE = 3} unit_mark_t;
sequence unit_hit(bit value);
  value;
endsequence

package pkg_cells;
  typedef enum int {START_VALUE = 7} package_mark_t;
  sequence package_hit(bit value);
    value;
  endsequence
endpackage

module test_package_and_unit_sequences_and_enum_labels;
  bit clock;
  bit pulse;
  int unit_count, package_count;
  unit_mark_t local_value = $unit::START_VALUE;
  pkg_cells::package_mark_t packaged_value = pkg_cells::START_VALUE;

  cover property (@(posedge clock) unit_hit(pulse)) unit_count++;
  cover property (@(posedge clock) pkg_cells::package_hit(!pulse)) package_count++;

  initial begin
    #2 clock = 1;
    #1 clock = 0;
    pulse = 1;
    #2 clock = 1;
    #1 $display("labels=%0d,%0d counts=%0d,%0d",
                local_value, packaged_value, unit_count, package_count);
  end
endmodule
