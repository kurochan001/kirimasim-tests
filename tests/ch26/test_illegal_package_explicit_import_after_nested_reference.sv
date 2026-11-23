/*
:name: test_illegal_package_explicit_import_after_nested_reference
:description: A name resolved through the enclosing module's wildcard import inside a function conflicts with a later explicit import into that module
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.3 26.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the reference in read_token imports nested_first::token into the module before its explicit import of nested_second::token
:expected_stderr_regex: ^(?![^\n]*(?i:unsupported|not supported|not implemented|syntax error))[^\n]*test_illegal_package_explicit_import_after_nested_reference\.sv:(?:28|33):(?:\d+:)?[^\n]*(?i:import[^\n]*(?:collid|conflict)|already[^\n]*import)
*/
package nested_first;
  localparam int token = 11;
  localparam int spare = 13;
endpackage

package nested_second;
  localparam int token = 22;
  localparam int spare = 23;
endpackage

module test_illegal_package_explicit_import_after_nested_reference;
  import nested_first::*;

  function automatic int read_token();
    return token;
  endfunction

  import nested_second::spare;  // unused wildcard candidate
  // Only token already has a binding in the module.
  import nested_second::token;
  initial $display("token=%0d spare=%0d", read_token(), spare);
endmodule
