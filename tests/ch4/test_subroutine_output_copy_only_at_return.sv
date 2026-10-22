/*
:name: test_subroutine_output_copy_only_at_return
:description: Task output and inout assignments remain local until the subroutine returns (IEEE 1800-2023 Section 4.9.7)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.7 13.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_subroutine_output_copy_only_at_return.expected
*/
// IEEE 1800-2023 4.9.7 13.5.1: Intermediate formal writes are hidden from the
// actual variables; return copies out their final values together.

module test_subroutine_output_copy_only_at_return;
  int a = 1, b = 2;
  task automatic change(output int x, inout int y);
    x = 7; y = 8;
    #4 x = 9;
  endtask
  initial begin
    fork change(a, b); join_none
    #1 $display("during=%0d,%0d", a, b);
    #4 $display("after=%0d,%0d", a, b);
  end
endmodule
