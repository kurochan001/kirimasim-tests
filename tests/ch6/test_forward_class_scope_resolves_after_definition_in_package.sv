/*
:name: test_forward_class_scope_resolves_after_definition_in_package
:description: The same class-scoped type is usable through a permitted alias and directly after completion
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.18
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_forward_class_scope_resolves_after_definition_in_package.expected
*/
package completed_type_pkg;
  typedef class owner;
  typedef owner::payload deferred_name;

  class owner;
    typedef logic [12:0] payload;
  endclass

  owner::payload direct_value;
  deferred_name alias_value;
endpackage

module test_forward_class_scope_resolves_after_definition_in_package;
  initial begin
    completed_type_pkg::direct_value = 13'h1234;
    completed_type_pkg::alias_value = completed_type_pkg::direct_value ^ 13'h00a5;
    $display("bits=%0d/%0d values=%h/%h",
             $bits(completed_type_pkg::direct_value), $bits(completed_type_pkg::alias_value),
             completed_type_pkg::direct_value, completed_type_pkg::alias_value);
  end
endmodule
