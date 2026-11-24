/*
:name: test_forward_type_qualified_typedef_and_type_parameter_before_completion
:description: An incomplete forward class type supports restricted qualified uses before its definition
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.18 6.20.3 6.23 8.23
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_forward_type_qualified_typedef_and_type_parameter_before_completion.expected
*/
module type_sink #(parameter type selected_type = bit) ();
  selected_type stored;
  initial begin
    stored = selected_type'(23);
    $display("parameter bits=%0d value=%0d", $bits(stored), stored);
  end
endmodule

module test_forward_type_qualified_typedef_and_type_parameter_before_completion;
  typedef class pending_type;
  typedef pending_type::payload_type early_alias;
  typedef type(pending_type::payload_type) early_type_query;
  type_sink #(pending_type::payload_type) instance_under_test();

  class pending_type;
    typedef logic [6:0] payload_type;
  endclass

  early_alias first;
  early_type_query second;

  initial begin
    #1;
    first = 7'd45;
    second = 7'd95;
    $display("aliases=%0d/%0d bits=%0d/%0d", first, second, $bits(first), $bits(second));
  end
endmodule
