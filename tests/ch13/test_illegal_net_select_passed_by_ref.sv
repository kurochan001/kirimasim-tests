/*
:name: test_illegal_net_select_passed_by_ref
:description: A select of a net cannot be the actual argument of a ref formal (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a bit-select of a net is passed to a ref formal
:expected_stderr_regex: test_illegal_net_select_passed_by_ref\.sv:33:
*/
// IEEE 1800-2023 §13.5.2: nets and selects of nets shall not be passed by
// reference. The ref actual here is a bit-select of the net bus; the same
// task called with a variable is legal.
// Icarus Verilog 13.0 does not support ref formals at all, so its
// rejection does not count.

module test_illegal_net_select_passed_by_ref;
  wire logic [3:0] bus;
  logic v;

  assign bus = 4'b1010;

  task automatic show(ref logic a);
    $display("%b", a);
  endtask

  initial begin
    v = 1'b0;
    show(v);
    show(bus[1]);   // illegal: a select of a net passed by reference
  end
endmodule
