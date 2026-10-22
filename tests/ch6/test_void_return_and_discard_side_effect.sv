/*
:name: test_void_return_and_discard_side_effect
:description: Void functions can return early and a void cast discards a value without discarding its side effect (IEEE 1800-2023 Section 6.13)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.13
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_void_return_and_discard_side_effect.expected
*/
// IEEE 1800-2023 6.13: A void return exits the function immediately; casting
// another function call to void still evaluates that call.

module test_void_return_and_discard_side_effect;
  int count;
  function automatic void apply(int n);
    if (n == 0) return;
    count += n;
  endfunction
  function automatic int take();
    count++;
    return 99;
  endfunction
  initial begin
    apply(0); apply(3); void'(take());
    $display("count=%0d", count);
  end
endmodule
