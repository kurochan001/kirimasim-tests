/*
:name: test_builtin_net_declarations_combine_advisory_strength_type_and_delay
:description: Built-in net declarations accept advisory, strength, packed type, delay triples and declarator assignments together
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3 10.3.1 6.6.4 6.9.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_builtin_net_declarations_combine_advisory_strength_type_and_delay.expected
*/
`timescale 1ns/1ns
module test_builtin_net_declarations_combine_advisory_strength_type_and_delay;
  logic [2:0] source = 3'b000;
  wire (strong1, weak0) vectored logic signed [3:1] #(2,3,4)
       driven = source, control = ~source;
  trireg (small) scalared logic signed [3:1] #(2,3,5) held;
  assign held = source;

  task automatic sample(input string label_text);
    $display("%s drive=%b control=%b held=%b", label_text, driven, control, held);
  endtask

  initial begin
    #6 sample("settled");
    #1 source = 3'b101;
    #1 sample("early");
    #3;
    sample("updated");
    $display("signed=%0d/%0d", driven, held);
    #1 source = 3'bzzz;
    #2 sample("retained");
    #6 sample("decayed");
    $finish(0);
  end
endmodule
