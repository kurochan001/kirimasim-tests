/*
:name: test_illegal_wildcard_shadow_use_leaves_later_names_ambiguous
:description: Using a local declaration in an earlier nested scope leaves the package candidates ambiguous at their first unqualified outer use
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.3 26.5 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the local token in the selected scope does not bind either wildcard candidate in the module
:expected_stderr_regex: test_illegal_wildcard_shadow_use_leaves_later_names_ambiguous\.sv:31:(?:\d+:)?[^\n]*(?i:(?=[^\n]*\btoken\b)[^\n]*(?:ambig|multiple (?:imports|packages)|both))
*/
package shadow_import_first;
  localparam int token = 11;
endpackage

package shadow_import_second;
  localparam int token = 37;
endpackage

module test_illegal_wildcard_shadow_use_leaves_later_names_ambiguous;
  import shadow_import_first::*;

  if (1) begin : selected
    localparam int token = 5;
    initial $display("local=%0d", token);
  end

  import shadow_import_second::*;
  localparam int ambiguous = token;
endmodule
