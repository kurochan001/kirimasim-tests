/*
:name: test_competing_nonblocking_writes_allow_either_last_writer
:description: Concurrent NBA writers allow either final value while ordered writes resolve to the last one
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2 4.6
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_competing_nonblocking_writes_allow_either_last_writer.expected
:expected_exit: 0
*/
`timescale 1ns/1ns
module test_competing_nonblocking_writes_allow_either_last_writer;
  int contested, ordered;

  initial begin
    #3;
    contested <= 7;
    ordered <= 11;
    ordered <= 17;
  end

  initial #3 contested <= 13;

  initial begin
    #4;
    $display("competing value allowed=%0d ordered last=%0d",
             contested == 7 || contested == 13, ordered);
  end
endmodule
