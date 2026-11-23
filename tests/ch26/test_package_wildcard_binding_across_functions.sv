/*
:name: test_package_wildcard_binding_across_functions
:description: A wildcard name first used in a nested function stays bound in the enclosing module when a sibling function sees another wildcard import
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 26.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_wildcard_binding_across_functions.expected
*/
package binding_first;
  localparam int token = 11;
  localparam int spare = 13;
endpackage

package binding_second;
  localparam int token = 22;
  localparam int spare = 23;
endpackage

module test_package_wildcard_binding_across_functions;
  import binding_first::*;

  function automatic int first_value();
    localparam int spare = 3;
    return 100 * token + spare;
  endfunction

  // Only token was imported into the module by first_value.
  import binding_second::spare;
  import binding_second::*;

  function automatic int sibling_value();
    return 100 * token + spare;
  endfunction

  initial $display("first=%0d sibling=%0d", first_value(), sibling_value());
endmodule
