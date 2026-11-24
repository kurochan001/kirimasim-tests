module defparam_chain_middle #(
  parameter int FIRST = 1, GAIN = 2, LAST = 3
);
  defparam_chain_leaf child();
  defparam child.CFG = FIRST + GAIN * 3;
endmodule
