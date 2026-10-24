/*
:name: test_isunbounded_package_and_hierarchical
:description: $isunbounded takes a package-scoped or a hierarchical parameter name and returns a bit that is 1 only for a parameter whose value is $ (IEEE 1800-2023 Section 6.20.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.7 20.6.3 20.6.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_isunbounded_package_and_hierarchical.expected
*/
// IEEE 1800-2023 §6.20.7 and §20.6.3: function bit $isunbounded(
// ps_parameter_identifier | hierarchical_parameter_identifier) returns 1
// when the parameter is $ and 0 otherwise. The arguments are parameters of a
// package, named with the package scope, and parameters of two instances,
// named hierarchically; one instance keeps the default $ and the other gets
// 3 by override. The result has the type bit (shown with $bits and
// $typename, §20.6.1); a parameter set to $ from another $ parameter is also
// unbounded. Icarus Verilog 13.0 does not parse $ as a parameter value.

package iub_pkg;
  parameter UNB = $;
  parameter BND = 4;
  parameter COPY = UNB;
endpackage

module iub_child #(parameter MAXV = $) ();
endmodule

module test_isunbounded_package_and_hierarchical;
  iub_child c1 ();
  iub_child #(.MAXV(3)) c2 ();

  initial begin
    $display("package: %b %b %b", $isunbounded(iub_pkg::UNB), $isunbounded(iub_pkg::BND),
             $isunbounded(iub_pkg::COPY));
    $display("hierarchical: %b %b", $isunbounded(c1.MAXV), $isunbounded(c2.MAXV));
    $display("bits: %0d %0d type: %s", $bits($isunbounded(iub_pkg::UNB)),
             $bits($isunbounded(c2.MAXV)), $typename($isunbounded(iub_pkg::BND)));
  end
endmodule
