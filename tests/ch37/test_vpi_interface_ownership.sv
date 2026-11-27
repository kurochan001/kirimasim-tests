/*
:name: test_vpi_interface_ownership
:description: Traverse interface ownership between programs, interface arrays, and specify paths
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.6 37.9 37.39 A.1.6 A.1.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @vpi_interface_ownership/client.c
:expected_stdout: @test_vpi_interface_ownership.expected
:files: vpi_interface_ownership/client.h vpi_interface_ownership/seed.cpp vpi_interface_ownership/seeded.expected
*/
`timescale 1ns/1ns

interface owner_link(input wire a, b);
  wire y;
  assign y = a & b;
`ifdef DIRECT_INTERFACE_SPECIFY
  specify
    (a => y) = 7;
  endspecify
`endif
endinterface

program owner_program(owner_link physical);
`ifdef DIRECT_PROGRAM_CHILDREN
  owner_link scalar_child(1'b1, 1'b0);
  owner_link array_child[2](1'b1, 1'b0);
`endif
  initial #3;
endprogram

module owner_timing(input wire a, b, output wire y);
  and signal_gate(y, a, b);
  specify
    (a => y) = 7;
    (b => y) = 11;
  endspecify
endmodule

module test_vpi_interface_ownership;
  logic a = 1, b = 1, control_b = 0;
  wire timing_out;

  owner_link left_path(a, b), right_path(a, control_b);
  owner_link left_scalar(a, b), right_scalar(a, control_b), physical(a, b);
  owner_link left_array[2](a, b), right_array[2](a, control_b), physical_array[2](a, b);
  owner_program left_program(physical), right_program(physical);
  owner_timing timing(a, b, timing_out);

  initial begin
    #1;
    $display("hdl paths=%b%b scalar=%b%b array=%b%b physical=%b%b",
             left_path.y, right_path.y, left_scalar.y, right_scalar.y,
             left_array[1].y, right_array[1].y, physical.y, physical_array[1].y);
    $vt_interface_owners;
    $display("hdl after probe=%b%b", left_path.y, right_path.y);
    $finish(0);
  end
endmodule
