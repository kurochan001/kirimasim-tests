/*
:name: test_vpi_put_value_side_effect
:description: vpi_put_value on an object whose index expression has a side effect is an error, while the same element with a plain index can be written (IEEE 1800-2023 Section 37.3.5)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.5 38.34 38.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_value_side_effect.c
:expected_stdout: @test_vpi_put_value_side_effect.expected
*/
// IEEE 1800-2023 §37.3.5: it shall be an error to apply vpi_put_value (38.34)
// to an object one of whose index expressions has side effects, such as the
// increment in mem[k++]. $vt_put writes 5 to its argument and asks
// vpi_chk_error (38.4) whether the call failed; for the argument mem[2],
// without side effects, it succeeds and mem[2] becomes 5.
//
// Icarus Verilog 13.0 stops on an internal assertion at the first
// vpi_put_value instead of reporting the error.

`timescale 1ns/1ns

module test_vpi_put_value_side_effect;
  int mem [0:3];
  int k = 1;

  initial begin
    $vt_put(mem[k++]);
    $vt_put(mem[2]);
    #1 $display("mem[2]=%0d", mem[2]);
  end
endmodule
