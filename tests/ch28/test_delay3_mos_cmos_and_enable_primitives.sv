/*
:name: test_delay3_mos_cmos_and_enable_primitives
:description: MOS and CMOS switches and a three-state gate use the three specified delays on rise, fall and turn-off
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3 28.3.2 28.3.3 28.7 28.9 28.16
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_delay3_mos_cmos_and_enable_primitives.expected
*/
`timescale 1ns/1ns
module test_delay3_mos_cmos_and_enable_primitives;
  logic data = 0, on = 1;
  wire mos_value, cmos_value, gate_value, resolved_gate;
  nmos #(2, 4, 6) pass_mos(mos_value, data, on);
  cmos #(2, 4, 6) pass_cmos(cmos_value, data, on, !on);
  bufif1 (strong1, weak0) #(2, 4, 6)
         gate_control(gate_value, data, on), gate_loaded(resolved_gate, data, on);
  pullup (pull1) load(resolved_gate);

  task automatic sample(input string label_text);
    $display("%s output=%b%b%b loaded=%b",
             label_text, mos_value, cmos_value, gate_value, resolved_gate);
  endtask

  initial begin
    #8 sample("settled");
    data = 1;
    #1 sample("rise before");
    #2 sample("rise after");
    #4 data = 0;
    #3 sample("fall before");
    #2 sample("fall after");
    #4 on = 0;
    #5 sample("off before");
    #2 sample("off after");
    $finish(0);
  end
endmodule
