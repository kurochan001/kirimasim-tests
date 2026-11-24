/*
:name: test_always_comb_nested_function_reacts_only_to_real_slice_changes
:description: The slice read through nested functions wakes always_comb only when its value changes
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2.1 4.3 11.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_nested_function_reacts_only_to_real_slice_changes.expected
*/
`timescale 1ns/1ns

module test_always_comb_nested_function_reacts_only_to_real_slice_changes;
  logic [15:0] payload = 16'h2a75;
  time nested_time, direct_time, dynamic_time;
  int slice_low_bit = 8;
  logic [3:0] nested_value, direct_value, dynamic_value;

  function automatic logic [3:0] inner();
    return payload[11:8];
  endfunction

  function automatic logic [3:0] outer();
    return inner() ^ 4'b0011;
  endfunction

  always_comb begin
    nested_value = outer();
    nested_time = $time;
  end

  always_comb begin
    direct_value = payload[11:8] ^ 4'b0011;
    direct_time = $time;
  end

  always_comb begin
    dynamic_value = payload[slice_low_bit +: 4] ^ 4'b0011;
    dynamic_time = $time;
  end

  task automatic report_sample(input string label_text);
    #1;
    $display("%s: nested=%h/%0d direct=%h/%0d dynamic=%h/%0d", label_text,
             nested_value, nested_time, direct_value, direct_time, dynamic_value, dynamic_time);
  endtask

  initial begin
    report_sample("initial");
    #1 payload[11:8] = 4'ha;
    report_sample("same blocking");
    #1 payload[7:4] = 4'hc;
    report_sample("disjoint blocking");
    #1 payload[11:8] <= 4'ha;
    report_sample("same nba");
    #1 payload[11:8] <= 4'h5;
    report_sample("changed nba");
    #1 payload[11:8] += 4'h0;
    report_sample("same compound");
    #1 payload[11:8] = 4'h3;
    report_sample("changed blocking");
    #1 slice_low_bit = 4;
    report_sample("changed selector");
  end
endmodule
