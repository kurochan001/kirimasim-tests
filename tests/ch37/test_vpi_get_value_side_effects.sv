/*
:name: test_vpi_get_value_side_effects
:description: Each vpi_get_value on a system task argument with side effects, a function call that changes a variable and a select whose index increments a variable, evaluates the expression again together with its side effects (IEEE 1800-2023 Section 37.3.5)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.5 37.42 38.15 11.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_value_side_effects.c
:expected_stdout: @test_vpi_get_value_side_effects.expected
*/
// IEEE 1800-2023 §37.3.5: applying vpi_get_value (38.15) to an expression with
// side effects fully evaluates it together with its side effects, such as a
// function call that changes the state of the simulation or an increment
// operator (11.4.2) in an index; §37.42 detail 7: arguments of a system task
// are evaluated only when an application asks for their value. $vt_twice reads
// the value of its argument twice. bump() increments n and returns 10 * n, so
// the reads give 10 and 20 and n is 2 afterwards; arr[k++] reads arr[0] and
// then arr[1] and leaves k at 2.
//
// Icarus Verilog 13.0 evaluates each argument once, when the task is called,
// and gives that value to both reads, so n and k end at 1.

module test_vpi_get_value_side_effects;
  int n = 0;
  int k = 0;
  int arr [0:3] = '{10, 20, 30, 40};

  function int bump();
    n = n + 1;
    return 10 * n;
  endfunction

  initial begin
    $vt_twice(bump());
    $display("n=%0d", n);
    $vt_twice(arr[k++]);
    $display("k=%0d", k);
  end
endmodule
