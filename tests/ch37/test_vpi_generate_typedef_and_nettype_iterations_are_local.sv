/*
:name: test_vpi_generate_typedef_and_nettype_iterations_are_local
:description: Each generate scope exposes only its explicitly declared typedefs and nettypes
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.85 37.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_generate_typedef_and_nettype_iterations_are_local.expected
:vpi_c: @test_vpi_generate_typedef_and_nettype_iterations_are_local.c
*/
module test_vpi_generate_typedef_and_nettype_iterations_are_local;
  typedef logic [7:0] at_top_t;
  nettype at_top_t at_top_net_t;
  at_top_net_t top_signal;

  if (1) begin : outer
    typedef logic [5:0] outer_word_t;
    nettype outer_word_t outer_bus_t;
    outer_bus_t outer_signal;

    if (1) begin : inner
      typedef logic [2:0] inner_word_t;
      nettype inner_word_t inner_bus_t;
      inner_bus_t inner_signal;
    end
  end

  initial #1 $finish;
endmodule
