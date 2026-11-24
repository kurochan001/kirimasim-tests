/*
:name: test_package_qualified_reference_leaves_later_named_import_available
:description: A package-qualified use through a function leaves the wildcard candidate unbound, allowing another package's later named import
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 26.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_qualified_reference_leaves_later_named_import_available.expected
*/
package qualified_origin;
  localparam int token = 11;
  localparam int unchanged = 19;
endpackage

package explicit_origin;
  localparam int token = 37;
  localparam int unchanged = 43;
endpackage

module test_package_qualified_reference_leaves_later_named_import_available;
  import qualified_origin::*;

  function automatic int qualified_call();
    return 100 * qualified_origin::token + qualified_origin::unchanged;
  endfunction

  import explicit_origin::token;
  localparam int local_token = token;
  localparam int wildcard_control = unchanged;

  initial
    $display("qualified=%0d explicit=%0d untouched=%0d",
             qualified_call(), local_token, wildcard_control);
endmodule
