/*
:name: test_checker_named_empty_binding_takes_precedence_over_wildcard
:description: A named empty checker connection uses its default while the wildcard connects the same-named signal
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.3 16.8 A.4.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_named_empty_binding_takes_precedence_over_wildcard.expected
*/
package checker_binding_observations;
  int hits[3];
endpackage

checker checker_binding_monitor(input bit clk, input bit gate = 1, input int slot = 0);
  observed: cover property (@(posedge clk) 1'b1)
    if (gate) checker_binding_observations::hits[slot]++;
endchecker

module test_checker_named_empty_binding_takes_precedence_over_wildcard;
  bit clk = 0, gate = 0;
  checker_binding_monitor empty_binding(
      .*, (* keep = 1 *) .gate(), .slot(0));
  checker_binding_monitor wildcard_binding(.slot(1), .*);
  checker_binding_monitor written_binding(.clk(clk), .gate(gate), .slot(2));

  initial begin
    #5 clk = 1;
    #1 clk = 0;
    gate = 1;
    #4 clk = 1;
    #1 $display("empty=%0d wildcard=%0d written=%0d",
                checker_binding_observations::hits[0],
                checker_binding_observations::hits[1],
                checker_binding_observations::hits[2]);
  end
endmodule
