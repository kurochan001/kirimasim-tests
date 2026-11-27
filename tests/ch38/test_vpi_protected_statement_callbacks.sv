/*
:name: test_vpi_protected_statement_callbacks
:description: Individual and module-wide VPI statement callback registration excludes protected statements
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1.1 38.36.1.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @vpi_protected_callbacks/probe.c
:expected_stdout: @test_vpi_protected_statement_callbacks.expected
:files: vpi_protected_callbacks/left.expected vpi_protected_callbacks/right.expected
*/
`timescale 1ns/1ps

module protected_callback_worker;
  int left_value, right_value, tail_value;

  initial begin : actions
    // left begin
    begin : left_actions
      #1;
      left_value = 29;
    end
    // left end
    // right begin
`pragma protect begin
    begin : right_actions
      #1;
      right_value = 47;
    end
`pragma protect end
    // right end
    #1;
    tail_value = 63;
  end
endmodule

module test_vpi_protected_statement_callbacks;
  protected_callback_worker worker();
  initial #4 $finish(0);
endmodule
