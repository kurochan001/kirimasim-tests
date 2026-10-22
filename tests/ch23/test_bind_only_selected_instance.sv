/*
:name: test_bind_only_selected_instance
:description: An instance targeted bind adds a monitor only to the selected instance of a repeated module type (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bind_only_selected_instance.expected
*/
// IEEE 1800-2023 23.11: The bound instance samples the target signal in its own
// scope; binding one hierarchical instance must not add a monitor to its
// sibling.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

module bind_target(input bit flag); endmodule
module bound_monitor(input bit flag);
  initial #2 $display("bound_flag=%0d", flag);
endmodule
module test_bind_only_selected_instance;
  bind_target left(1'b0), right(1'b1);
  bind bind_target : test_bind_only_selected_instance.right bound_monitor monitor(.flag(flag));
  initial #3 $finish;
endmodule
