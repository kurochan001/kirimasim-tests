/*
:name: test_illegal_hierarchical_reference_to_let
:description: a let declaration cannot be referenced hierarchically (IEEE 1800-2023 Section 11.12)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the continuous assignment to e uses g.inv_and(a), a hierarchical reference to the let inv_and declared in the generate block g
:expected_stderr_regex: test_illegal_hierarchical_reference_to_let\.sv:33:
*/
// IEEE 1800-2023 §11.12: a let may be declared in a generate block and used
// there, but no hierarchical references to let declarations are allowed.
// The let both of the module and the let inv_and used inside its generate
// block g are legal; the use of g.inv_and from the module is not.
// Icarus Verilog 13.0 does not support let declarations.
// The design is accepted by the 5.052 release of Verilator.

module test_illegal_hierarchical_reference_to_let;
  logic a = 1'b0, b = 1'b1;
  wire d, e, f;

  let both(x, y) = x && y;
  assign f = both(a, b);

  if (1) begin : g
    let inv_and(x) = !x && b;
    assign d = inv_and(a);
  end

  assign e = g.inv_and(a);   // illegal: a hierarchical reference to a let

  initial #1 $display("%b %b", d, f);
endmodule
