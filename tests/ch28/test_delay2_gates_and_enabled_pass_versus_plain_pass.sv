/*
:name: test_delay2_gates_and_enabled_pass_versus_plain_pass
:description: Two-delay gates and enabled pass switches propagate after their selected delays while plain pass and pull primitives have no delay
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3 28.3.2 28.3.3 28.8 28.10 28.16
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_delay2_gates_and_enabled_pass_versus_plain_pass.expected
*/
`timescale 1ns/1ns
module test_delay2_gates_and_enabled_pass_versus_plain_pass;
  logic data = 0, on = 0;
  wire driven, from_and, from_buf, loaded_buf, from_enabled, from_plain, pulled_low, pulled_high;
  assign driven = data;
  and (strong1, weak0) #(2, 4) delayed_and(from_and, data, 1'b1);
  buf (strong1, weak0) #(2, 4) delayed_buf(from_buf, loaded_buf, data);
  pullup (pull1) buf_load(loaded_buf);
  tranif1 #(3, 5) enabled_link(from_enabled, driven, on);
  tran plain_link(from_plain, driven);
  pulldown (weak0) low_source(pulled_low);
  pullup (weak1) high_source(pulled_high);

  task automatic sample(input string label_text);
    $display("%s gates=%b%b pass=%b%b pulls=%b%b%b", label_text, from_and, from_buf,
             from_enabled, from_plain, loaded_buf, pulled_low, pulled_high);
  endtask

  initial begin
    #7 sample("settled");
    on = 1;
    #2 sample("enable before");
    #2 sample("enable after");
    data = 1;
    #1 sample("rise before");
    #2 sample("rise after");
    data = 0;
    #3 sample("fall before");
    #2 sample("fall after");
    on = 0;
    #4 sample("disable before");
    #2 sample("disable after");
    $finish(0);
  end
endmodule
