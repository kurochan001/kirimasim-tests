/*
:name: test_case_qualifier_flush_is_local_to_retriggered_process
:description: A transient unique case report is cleared on event control reentry while another process reports its stable miss
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.3.1 12.4.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_case_qualifier_flush_is_local_to_retriggered_process.expected
:expected_stderr_regex: (?ms)\A(?!.*?^(?=[^\n]*test_case_qualifier_flush_is_local_to_retriggered_process\.sv:21:)(?=[^\n]*(?i:warning|error|violation))(?=[^\n]*(?i:\b(unique|case)\b))[^\n]+)(?=.*?^(?=[^\n]*test_case_qualifier_flush_is_local_to_retriggered_process\.sv:29:)(?=[^\n]*(?i:warning|error|violation))(?=[^\n]*(?i:\b(priority|case)\b))[^\n]+)
*/
`timescale 1ns/1ns
module test_case_qualifier_flush_is_local_to_retriggered_process;
  int transient_selector, stable_selector;
  int transient_visits, stable_visits;
  int transient_result, stable_result;

  always @(transient_selector) begin : retriggered
    unique case (transient_selector)
      0: transient_result = 10;
      1: transient_result = 11;
    endcase
    if (transient_selector == 7) transient_visits++;
  end

  always @(stable_selector) begin : independent_process
    priority case (stable_selector)
      0: stable_result = 20;
      1: stable_result = 21;
    endcase
    if (stable_selector == 8) stable_visits++;
  end

  initial begin
    #1 transient_selector = 1;
    stable_selector = 1;
    #4 transient_selector = 7;
    transient_selector <= 0;
    stable_selector = 8;
    #1 $display("visited transient=%0d stable=%0d", transient_visits, stable_visits);
    $display("outputs transient=%0d stable=%0d", transient_result, stable_result);
  end
endmodule
