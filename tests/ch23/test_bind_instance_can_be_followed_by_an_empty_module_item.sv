/*
:name: test_bind_instance_can_be_followed_by_an_empty_module_item
:description: Instance-target bind uses one terminator and can be followed by an independent empty module item
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11 26.2 A.1.4 A.1.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bind_instance_can_be_followed_by_an_empty_module_item.expected
*/
module bind_observer #(parameter int ADDEND = 0)(input var int sample, output int observed);
  assign observed = sample + ADDEND;
endmodule
module empty_item_target;
  int payload;
  int result;
endmodule
module test_bind_instance_can_be_followed_by_an_empty_module_item;
  empty_item_target nodes [3:5]();

  bind test_bind_instance_can_be_followed_by_an_empty_module_item.nodes[3]
      bind_observer #(.ADDEND(5)) first_attachment
      (.sample(payload), .observed(result));
  // The second semicolon is a separate empty module item.
  bind test_bind_instance_can_be_followed_by_an_empty_module_item.nodes[5]
      bind_observer #(.ADDEND(7)) last_attachment
      (.sample(payload), .observed(result));;

  initial begin
    nodes[3].payload = 11;
    nodes[4].payload = 22;
    nodes[5].payload = 33;
    #1 $display("bound outputs=%0d/%0d/%0d", nodes[3].result, nodes[4].result, nodes[5].result);
  end
endmodule
