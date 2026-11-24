/*
:name: test_property_precedence_if_case_and_abort
:description: Conditional and abort properties consume their Boolean body expressions
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_precedence_if_case_and_abort.expected
*/
`timescale 1ns/1ns
module test_property_precedence_if_case_and_abort;
  bit clk, choose;
  bit low = 0, high = 1, abort_now = 1;
  int failed_accept = 0, failed_sync_accept = 0;
  int failed_reject = 0, failed_sync_reject = 0;
  int failed_if = 0, failed_case = 0;

  a1: assert property (@(posedge clk) accept_on(abort_now) low and low)
    else failed_accept++;
  a2: assert property (@(posedge clk) sync_accept_on(abort_now) low and low)
    else failed_sync_accept++;
  a3: assert property (@(posedge clk) reject_on(abort_now) high or high)
    else failed_reject++;
  a4: assert property (@(posedge clk) sync_reject_on(abort_now) high or high)
    else failed_sync_reject++;

  a5: assert property (@(posedge clk) if (choose) low else low or high)
    else failed_if++;
  a6: assert property (@(posedge clk) case (choose)
    1: low or high;
    default: low;
  endcase) else failed_case++;

  task automatic report_failures;
    $display("accept=%0d/%0d reject=%0d/%0d if=%0d case=%0d",
             failed_accept, failed_sync_accept, failed_reject,
             failed_sync_reject, failed_if, failed_case);
  endtask

  initial begin
    choose = 1;
    #5 clk = 1;
    #1 report_failures();
    #4 clk = 0;
    choose = 0;
    #5 clk = 1;
    #1 report_failures();
  end
endmodule
