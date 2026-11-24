/*
:name: test_highz_gate_strength_suppresses_one_logic_value
:description: High impedance strength suppresses just one logic value on enabled three state gates
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_highz_gate_strength_suppresses_one_logic_value.expected
*/
module test_highz_gate_strength_suppresses_one_logic_value;
  logic data, enable;
  wire suppress_one, suppress_zero;
  bufif1 (highz1, strong0) zero_path(suppress_one, data, enable);
  bufif1 (highz0, strong1) one_path(suppress_zero, data, enable);

  initial begin
    enable = 1;
    data = 0;
    #1 $display("enabled zero=%b,%b", suppress_one, suppress_zero);
    data = 1;
    #1 $display("enabled one=%b,%b", suppress_one, suppress_zero);
    enable = 0;
    #1 $display("disabled=%b,%b", suppress_one, suppress_zero);
  end
endmodule
