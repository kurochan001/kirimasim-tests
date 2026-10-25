/*
:name: test_illegal_net_passed_by_ref
:description: A net cannot be the actual argument of a ref formal (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a net is passed to a ref formal
:expected_stderr_regex: test_illegal_net_passed_by_ref\.sv:34:
*/
// IEEE 1800-2023 §13.5.2: nets and selects of nets shall not be passed by
// reference; only variables, class properties, members of unpacked
// structures and elements of unpacked arrays can be. The ref actual here is
// the net w; the same task called with a variable is legal.
// Icarus Verilog 13.0 does not support ref formals at all, so its
// rejection does not count.

module test_illegal_net_passed_by_ref;
  wire logic w;
  logic v;

  assign w = 1'b1;

  task automatic show(ref logic a);
    $display("%b", a);
  endtask

  initial begin
    v = 1'b0;
    show(v);
    show(w);   // illegal: a net passed by reference
  end
endmodule
