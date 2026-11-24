/*
:name: test_uwire_nonmerge_warns_when_port_width_conversion_is_required
:description: Width conversion prevents a single merged uwire across input and output ports and requires a warning
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.6 23.3.3.7 23.3.3.3 6.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_uwire_nonmerge_warns_when_port_width_conversion_is_required.expected
:expected_stderr_regex: (?ims)\A(?=.*?^(?=[^\n]*warning)(?=[^\n]*(?:ingress_adapted|narrow_actual))(?=[^\n]*\buwire\b)(?=[^\n]*(?:merg|collaps|unresolved|single.driver))[^\n]+)(?=.*?^(?=[^\n]*warning)(?=[^\n]*(?:egress_adapted|wide_actual))(?=[^\n]*\buwire\b)(?=[^\n]*(?:merg|collaps|unresolved|single.driver))[^\n]+)(?=.*?^(?=[^\n]*warning)(?=[^\n]*(?:ingress_external|narrow_uwire))(?=[^\n]*\buwire\b)(?=[^\n]*(?:merg|collaps|unresolved|single.driver))[^\n]+)(?=.*?^(?=[^\n]*warning)(?=[^\n]*(?:egress_external|wide_uwire))(?=[^\n]*\buwire\b)(?=[^\n]*(?:merg|collaps|unresolved|single.driver))[^\n]+)
*/
module wide_input(input uwire signed [4:0] input_port, output wire [4:0] observed);
  assign observed = input_port;
endmodule
module short_output(input wire [1:0] stimulus, output uwire [1:0] output_port);
  assign output_port = stimulus;
endmodule
module ordinary_wide_input(input wire signed [4:0] input_port,
                           output wire [4:0] observed);
  assign observed = input_port;
endmodule
module ordinary_short_output(input wire [1:0] stimulus, output wire [1:0] output_port);
  assign output_port = stimulus;
endmodule
module test_uwire_nonmerge_warns_when_port_width_conversion_is_required;
  logic signed [1:0] stimulus;
  wire signed [1:0] narrow_actual;
  wire [4:0] input_value, wide_actual, external_input_value;
  uwire signed [1:0] narrow_uwire;
  uwire [4:0] wide_uwire;
  assign narrow_actual = stimulus;
  assign narrow_uwire = stimulus;

  wide_input ingress_adapted(.input_port(narrow_actual), .observed(input_value));
  short_output egress_adapted(.stimulus(stimulus), .output_port(wide_actual));
  ordinary_wide_input ingress_external(.input_port(narrow_uwire),
                                       .observed(external_input_value));
  ordinary_short_output egress_external(.stimulus(stimulus), .output_port(wide_uwire));

  initial begin
    stimulus = 2'b01;
    #1 $display("positive internal=%b/%b external=%b/%b",
                input_value, wide_actual, external_input_value, wide_uwire);
    stimulus = 2'b10;
    #1 $display("negative internal=%b/%b external=%b/%b",
                input_value, wide_actual, external_input_value, wide_uwire);
  end
endmodule
