/*
:name: test_vpi_put_rejects_hidden_side_effects_in_index_calls
:description: A pure function index remains writable while calls with side effects are rejected even inside arithmetic
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.5 38.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_value_rejects_side_effect_in_bit_select_index.c
:expected_stdout: @test_vpi_put_rejects_hidden_side_effects_in_index_calls.expected
:expected_stderr_regex: (?m)^put error=1$\nafter direct=0022$\nput error=1$\nafter nested=0022$
*/
`timescale 1ns/1ns
module test_vpi_put_rejects_hidden_side_effects_in_index_calls;
  bit [15:0] payload;
  int function_calls = 0;

  function automatic int ordinary_index(input int position);
    return position + 1;
  endfunction

  function automatic int observed_index(input int position);
    function_calls++;
    return position + 1;
  endfunction

  initial begin
    #1 $vt_put_bit(payload[1]);
    $display("fixed=%04h", payload);
    $vt_put_bit(payload[ordinary_index(4)]);
    $display("pure=%04h", payload);
    $vt_put_bit(payload[observed_index(7)]);
    $display("after direct=%04h", payload);
    $vt_put_bit(payload[8 + observed_index(2)]);
    $display("after nested=%04h", payload);
    $finish(0);
  end
endmodule
