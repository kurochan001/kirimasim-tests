/*
:name: test_bind_output_port_drives_pulled_net_in_target_scope
:description: An output of a bound module drives a pulled net in the target like a local instance output
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11 23.3.3 6.6.5 28.15
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bind_output_port_drives_pulled_net_in_target_scope.expected
*/
module pulled_link_driver(input wire [7:0] src, output wire [7:0] driven);
  assign driven = src;
endmodule

module pulled_link_target(input wire [7:0] stimulus);
  tri0 [7:0] through_bind, ordinary, always_pulled;
  wire [7:0] no_pull;
  pulled_link_driver locally_instantiated(stimulus, ordinary);
endmodule

module test_bind_output_port_drives_pulled_net_in_target_scope;
  logic [7:0] stimulus;
  pulled_link_target target(stimulus);
  bind pulled_link_target pulled_link_driver bound_pulled(stimulus, through_bind);
  bind pulled_link_target pulled_link_driver bound_plain(stimulus, no_pull);

  task automatic show(input string label_text);
    #1;
    $display("%s bound=%h local=%h no-pull=%h undriven=%h", label_text,
             target.through_bind, target.ordinary, target.no_pull, target.always_pulled);
  endtask

  initial begin
    stimulus = 8'h29;
    show("high");
    stimulus = 8'hzz;
    show("released");
    stimulus = 8'h82;
    show("new");
    $finish(0);
  end
endmodule
