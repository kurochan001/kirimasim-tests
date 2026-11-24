/*
:name: test_vpi_simulated_net_is_shared_across_interconnect_merges
:description: A mandatory interconnect merge exposes one simulated net across each hierarchy and retains separate nets for different merges
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 23.3.3.7.1 6.6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_simulated_net_is_shared_across_interconnect_merges.expected
:vpi_c: @test_vpi_simulated_net_is_shared_across_interconnect_merges.c
*/
module simulated_merge_driver(input wire pattern, inout wand bus);
  assign bus = pattern;
endmodule

module simulated_merge_branch(input wire pattern, inout interconnect link);
  simulated_merge_driver drive(pattern, link);
endmodule

module simulated_merge_read(inout wand bus, output wire observation);
  assign observation = bus;
endmodule

module test_vpi_simulated_net_is_shared_across_interconnect_merges;
  interconnect left_net, right_net;
  wire left_read, right_read;
  simulated_merge_branch left_a(1'b1, left_net);
  simulated_merge_branch left_b(1'b0, left_net);
  simulated_merge_branch right_a(1'b1, right_net);
  simulated_merge_branch right_b(1'b1, right_net);
  simulated_merge_read watch_left(left_net, left_read);
  simulated_merge_read watch_right(right_net, right_read);

  initial begin
    #1 $vt_simulated_nets;
    $display("resolved=%b %b", left_read, right_read);
  end
endmodule
