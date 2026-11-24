/*
:name: test_vpi_refuses_force_release_disable_callbacks_on_variable_bits
:description: Force, release, and disable callbacks reject a variable bit select while corresponding eligible objects receive notifications
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_refuses_force_release_disable_callbacks_on_variable_bits.expected
:expected_stderr_regex: (?m)^refused force=1 release=1 disable=1$
:vpi_c: @test_vpi_refuses_force_release_disable_callbacks_on_variable_bits.c
*/
`timescale 1ns/1ns

module test_vpi_refuses_force_release_disable_callbacks_on_variable_bits;
  wire [1:0] regular = '0;
  logic [1:0] variable_bits = '0;

  initial begin : watched_begin
    #100 $display("disabled block continued");
  end

  initial begin
    #1 $vt_select_callback_setup;
    #4 force regular[1] = 1'b1;
    force variable_bits = 2'b11;
    #1 $display("forced net=%b variable=%b", regular, variable_bits);
    #4 release regular[1];
    release variable_bits;
    #1 $display("released net=%b variable=%b", regular, variable_bits);
    #4 disable watched_begin;
    #1 $vt_select_callback_report;
  end
endmodule
