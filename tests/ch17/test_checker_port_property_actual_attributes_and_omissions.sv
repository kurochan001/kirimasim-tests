/*
:name: test_checker_port_property_actual_attributes_and_omissions
:description: Ordered and named checker ports accept property actuals, attributes and omitted defaulted connections
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.3 17.2 A.4.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_port_property_actual_attributes_and_omissions.expected
*/
package observations;
  int hits [3];
endpackage
checker watch_property(property tested, bit guard = 1'b1, int key = 2);
  hit: cover property (tested) if (guard) observations::hits[key]++;
endchecker
module test_checker_port_property_actual_attributes_and_omissions;
  bit clock, stimulus, guard;
  property selected;
    @(posedge clock) stimulus;
  endproperty

  direct_control: cover property (selected) observations::hits[0]++;

  watch_property by_order((* coverage_port = 1 *) selected, , 1);
  watch_property by_name((* coverage_port = 1 *) .tested(selected), .guard);

  initial begin
    #1 stimulus = 1;
    #4 clock = 1;
    #1 clock = 0;
    guard = 1;
    #4 clock = 1;
    #1 $display("direct=%0d ordered=%0d named=%0d",
                observations::hits[0], observations::hits[1], observations::hits[2]);
  end
endmodule
