/*
:name: test_bind_scope_instance_list_selects_nonadjacent_targets
:description: A bind scope and its comma-separated target list instrument only the named instances
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11 A.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bind_scope_instance_list_selects_nonadjacent_targets.expected
*/
module bind_client(input wire [7:0] amount, output wire [7:0] observed);
  assign observed = amount + 8'd7;
endmodule
module scope_target #(parameter int ID = 0);
  wire [7:0] amount = 8'(ID);
  wire [7:0] result;
endmodule
module test_bind_scope_instance_list_selects_nonadjacent_targets;
  scope_target #(11) chosen_left();
  scope_target #(22) omitted();
  scope_target #(33) chosen_right();
  bind scope_target: chosen_left, chosen_right
      bind_client attached(.amount(amount), .observed(result));

  initial begin
    #1 $display("targets=%0d/%b/%0d", chosen_left.result, omitted.result === 'z,
                chosen_right.result);
  end
endmodule
