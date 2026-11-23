/*
:name: test_real_typedef_class_property_retains_fraction
:description: A real typedef property retains the same negative fraction as a real property (IEEE 1800-2023 Section 6.18)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.18 6.12
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_typedef_class_property_retains_fraction.expected
:expected_exit: 0
*/
// The typedef denotes real. Assign the exactly representable value -12.75 to
// both fields and compare each to the original.

module test_real_typedef_class_property_retains_fraction;
  typedef real sample_t;
  class holder;
    sample_t alias_field;
    real direct_field;
  endclass

  initial begin
    holder h;
    real value;
    h = new;
    value = -12.75;
    h.alias_field = value;
    h.direct_field = value;
    $display("CHECK alias=%0d direct=%0d", h.alias_field == value, h.direct_field == value);
    $finish;
  end
endmodule
