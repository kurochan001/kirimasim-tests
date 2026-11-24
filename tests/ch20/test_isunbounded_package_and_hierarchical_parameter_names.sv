/*
:name: test_isunbounded_package_and_hierarchical_parameter_names
:description: Isunbounded accepts package-qualified and hierarchical parameter names with bounded and unbounded values
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_isunbounded_package_and_hierarchical_parameter_names.expected
*/
package limits;
  parameter dynamic_limit = $;
  parameter fixed_limit = 7;
endpackage

module range_holder #(parameter LIMIT = 0);
endmodule

module test_isunbounded_package_and_hierarchical_parameter_names;
  range_holder #($) unlimited();
  range_holder #(5) limited();

  initial begin
    $display("package=%b%b", $isunbounded(limits::dynamic_limit),
             $isunbounded(limits::fixed_limit));
    $display("hierarchical=%b%b", $isunbounded(unlimited.LIMIT),
             $isunbounded(limited.LIMIT));
  end
endmodule
