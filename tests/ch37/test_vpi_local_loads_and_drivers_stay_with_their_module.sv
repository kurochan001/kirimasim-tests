/*
:name: test_vpi_local_loads_and_drivers_stay_with_their_module
:description: Local net iterators include the owning module's primitives, assignments and ports across collapsed or separate connections
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 23.3.3.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_vpi_local_loads_and_drivers_stay_with_their_module.expected
:vpi_c: @test_vpi_local_loads_and_drivers_stay_with_their_module.c
*/
`timescale 1ns/1ns

module local_net_receiver(input wire sample, inout wire shared,
                          input logic drive, output wire copied);
  wire common_read;
  assign shared = drive ? 1'b1 : 1'bz;
  buf read_input(copied, sample);
  buf read_common(common_read, shared);
endmodule

module test_vpi_local_loads_and_drivers_stay_with_their_module;
  logic a = 1, drive_child = 0, gate_input = 1;
  wire joined, top_read, child_read, separate, separate_read;

  assign joined = a;
  assign separate = a;
  buf read_parent(top_read, joined);
  local_net_receiver child(joined, joined, drive_child, child_read);
  local_net_receiver with_expr(separate & gate_input, separate, drive_child, separate_read);

  initial begin
    #1 $vt_local_net_relations;
    $display("connected=%b%b%b%b", top_read, child_read, child.common_read, separate_read);
  end
endmodule
