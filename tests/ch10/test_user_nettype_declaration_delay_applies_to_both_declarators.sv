/*
:name: test_user_nettype_declaration_delay_applies_to_both_declarators
:description: A user nettype declaration gives its two declarators the same propagation delay while preserving resolution
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3 10.3.1 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_user_nettype_declaration_delay_applies_to_both_declarators.expected
*/
`timescale 1ns/1ns
module test_user_nettype_declaration_delay_applies_to_both_declarators;
  typedef logic [7:0] word_t;

  function automatic word_t sum_drivers(input word_t values[]);
    word_t total = 0;
    foreach (values[i]) total = total + values[i];
    return total;
  endfunction

  nettype word_t summed_wire with sum_drivers;
  word_t left_source = 8'd17, right_source = 8'd11;
  summed_wire #(3) delayed_left, delayed_right;
  summed_wire immediate;
  wire [7:0] #(3) builtin_delayed = left_source + right_source;

  assign delayed_left = left_source;
  assign delayed_left = right_source;
  assign delayed_right = right_source;
  assign delayed_right = left_source;
  assign immediate = left_source;
  assign immediate = right_source;

  task automatic sample(input string name);
    $display("%s delayed=%0d/%0d immediate=%0d plain=%0d", name,
             delayed_left, delayed_right, immediate, builtin_delayed);
  endtask

  initial begin
    #6 sample("settled");
    #1 left_source = 8'd31;
    #1 sample("before left");
    #3 sample("after left");
    #1 right_source = 8'd25;
    #1 sample("before right");
    #3 sample("after right");
    $finish(0);
  end
endmodule
