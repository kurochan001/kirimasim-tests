// Parameter override of test_defparam_positions_and_hierarchy (IEEE 1800-2023
// 23.10.1): a defparam in a separate source file changes the parameter of an
// instance in the test module.

module defparam_positions_override;
  defparam test_defparam_positions_and_hierarchy.u4.A = 11;
endmodule
