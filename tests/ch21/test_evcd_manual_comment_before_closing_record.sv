/*
:name: test_evcd_manual_comment_before_closing_record
:description: A manual comment before the EVCD closing command preserves the earlier changes and final time
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.3.6 21.7.3.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: closing comment fixture finished
*/

`timescale 1ns/1ns
module closing_comment_ports(input wire a, output wire y);
  assign y = ~a;
endmodule

module test_evcd_manual_comment_before_closing_record;
  bit a = 0;
  wire y;
  closing_comment_ports target(a, y);

  initial begin
    $dumpports(target, "closing.evcd");
    #2 a = 1;
    #7 $display("closing comment fixture finished");
  end
endmodule
