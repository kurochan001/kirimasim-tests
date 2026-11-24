/*
:name: test_defparam_across_files_propagates_overridden_parent_parameter
:description: Cross-file defparams resolve before time zero even when a later override changes their value
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.1 C.4.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_defparam_across_files_propagates_overridden_parent_parameter.expected
:files: defparam_chain_middle.sv defparam_chain_leaf.sv
*/
module test_defparam_across_files_propagates_overridden_parent_parameter;
  defparam dut.FIRST = 7;
  defparam dut.GAIN = 11;
  defparam_chain_middle dut();
  defparam dut.LAST = 17;

  initial $display("before=%0d child=%0d after=%0d",
                   dut.FIRST, dut.child.CFG, dut.LAST);
endmodule
