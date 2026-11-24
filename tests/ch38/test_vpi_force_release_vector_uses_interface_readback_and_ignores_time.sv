/*
:name: test_vpi_force_release_vector_uses_interface_readback_and_ignores_time
:description: A vector force and release ignore a supplied time and return current driver data in an interface-owned release buffer
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 10.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_force_release_vector_uses_interface_readback_and_ignores_time.c
:expected_stdout: @test_vpi_force_release_vector_uses_interface_readback_and_ignores_time.expected
*/
`timescale 1ns/1ns

module test_vpi_force_release_vector_uses_interface_readback_and_ignores_time;
  logic [67:0] driver = 68'h1_0123_4567_89ab_cdef;
  wire [67:0] bus;
  assign bus = driver;

  initial begin
    #1;
    $vt_vector_force;
    $display("forced immediately=%h", bus);
    driver = 68'h8_a55a_1234_56xz_c0de;
    #1;
    $display("while forced=%h", bus);
    $vt_vector_release;
    $display("released immediately=%h", bus);
    #1;
    $display("released after settling=%h", bus);
    $finish(0);
  end
endmodule
