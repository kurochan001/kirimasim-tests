/*
:name: test_always_comb_function_global_ignores_redundant_whole_writes
:description: Whole writes of an unchanged value leave a function-dependent always_comb dormant after another input has changed
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2.1 4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_function_global_ignores_redundant_whole_writes.expected
*/
`timescale 1ns/1ns

module test_always_comb_function_global_ignores_redundant_whole_writes;
  int watched = 2;
  int direct_input = 1;
  int function_result, direct_result;
  time function_time, direct_time;

  function automatic int read_global();
    return watched;
  endfunction

  always_comb begin
    function_result = read_global() + direct_input;
    function_time = $time;
  end

  always_comb begin
    direct_result = watched + direct_input;
    direct_time = $time;
  end

  task automatic report_sample(input string label_text);
    #1;
    $display("%s: function=%0d/%0d direct=%0d/%0d", label_text,
             function_result, function_time, direct_result, direct_time);
  endtask

  initial begin
    report_sample("initial");
    #1 direct_input = 7;
    report_sample("other input");
    #1 watched = 2;
    report_sample("redundant blocking");
    #1 watched <= 2;
    report_sample("redundant nba");
    #1 watched += 0;
    report_sample("redundant compound");
    #1 watched <= 4;
    report_sample("changed nba");
    #1 watched = 5;
    report_sample("changed blocking");
  end
endmodule
