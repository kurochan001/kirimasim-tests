/*
:name: test_wildcard_reference_in_generate_binds_name_in_enclosing_scope
:description: An unqualified use in a generate scope binds the enclosing wildcard import before a later competing import
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 26.5 27.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wildcard_reference_in_generate_binds_name_in_enclosing_scope.expected
*/
package generate_import_first;
  int token = 11;
endpackage

package generate_import_second;
  int token = 37;
endpackage

module test_wildcard_reference_in_generate_binds_name_in_enclosing_scope;
  import generate_import_first::*;

  if (1) begin : selected
    initial token += 5;
  end

  import generate_import_second::*;
  initial #1
    $display("bound=%0d first=%0d second=%0d",
             token, generate_import_first::token, generate_import_second::token);
endmodule
