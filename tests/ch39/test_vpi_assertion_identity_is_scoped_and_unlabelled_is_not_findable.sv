/*
:name: test_vpi_assertion_identity_is_scoped_and_unlabelled_is_not_findable
:description: The same assertion label denotes different objects in separate instances
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.3.1 16.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_assertion_identity_is_scoped_and_unlabelled_is_not_findable.expected
:vpi_c: @test_vpi_assertion_identity_is_scoped_and_unlabelled_is_not_findable.c
*/
`timescale 1ns/1ns
module assertion_identity_leaf(input bit clk);
  test_label: assert property (@(posedge clk) 1'b1);
  assert property (@(posedge clk) 1'b1);
endmodule

module test_vpi_assertion_identity_is_scoped_and_unlabelled_is_not_findable;
  bit clk;
  assertion_identity_leaf left(clk);
  assertion_identity_leaf right(clk);

  initial begin
    #1 $vt_check_identity;
    #4 clk = 1;
  end
endmodule
