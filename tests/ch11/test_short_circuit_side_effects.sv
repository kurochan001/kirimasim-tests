/*
:name: test_short_circuit_side_effects
:description: &&, ||, -> and ?: skip the side effects of operands they do not need, while bitwise operators evaluate every operand (IEEE 1800-2023 Section 11.3.5)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.5 11.4.7 11.4.11
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_short_circuit_side_effects.expected
*/
// IEEE 1800-2023 §11.3.5: &&, ||, -> and ?: use short-circuit evaluation: an
// operand whose value is not needed for the result is not evaluated, so its
// side effects do not happen (11.4.7, 11.4.11). Every other operator evaluates
// all of its operands, so a function called as an operand of & or | always
// runs.

module test_short_circuit_side_effects;
  int calls;
  bit r;
  int t;

  function automatic bit touch(bit v);
    calls++;
    return v;
  endfunction

  initial begin
    calls = 0; r = 0 && touch(1);   $display("0 && f: r=%0d calls=%0d", r, calls);
    calls = 0; r = 1 || touch(0);   $display("1 || f: r=%0d calls=%0d", r, calls);
    calls = 0; r = 1 && touch(1);   $display("1 && f: r=%0d calls=%0d", r, calls);
    calls = 0; r = 0 || touch(1);   $display("0 || f: r=%0d calls=%0d", r, calls);
    calls = 0; r = 0 -> touch(0);   $display("0 -> f: r=%0d calls=%0d", r, calls);
    calls = 0; r = 1 -> touch(0);   $display("1 -> f: r=%0d calls=%0d", r, calls);
    calls = 0; t = 1 ? 5 : touch(1); $display("1 ? 5 : f: t=%0d calls=%0d", t, calls);
    calls = 0; t = 0 ? touch(1) : 7; $display("0 ? f : 7: t=%0d calls=%0d", t, calls);
    calls = 0; r = 0 & touch(1);    $display("0 & f: r=%0d calls=%0d", r, calls);
    calls = 0; r = 1 | touch(0);    $display("1 | f: r=%0d calls=%0d", r, calls);
  end
endmodule
