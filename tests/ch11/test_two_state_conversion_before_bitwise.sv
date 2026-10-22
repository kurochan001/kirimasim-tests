/*
:name: test_two_state_conversion_before_bitwise
:description: Conversion to a two state type maps unknown bits to zero before later bitwise operations (IEEE 1800-2023 Section 11.3.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_two_state_conversion_before_bitwise.expected
*/
// IEEE 1800-2023 11.3.4: Assignment into bit data removes x and z bits, so a
// later inversion observes zero bits rather than propagating unknowns.
// Oracle checks: The 5.052 release is a two-state engine and is not used as the
// oracle here.

module test_two_state_conversion_before_bitwise;
  logic [3:0] source = 4'b1xz0;
  bit [3:0] converted;
  initial begin
    converted = source;
    $display("converted=%b inverted=%b source_unknown=%0d", converted, ~converted,
             $isunknown(source));
  end
endmodule
