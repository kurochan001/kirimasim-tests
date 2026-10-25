/*
:name: test_constant_function_call_fresh_initial_values
:description: Each constant function call at elaboration starts from the initial values of the function's variables, and the calls made at elaboration leave no trace in those variables at simulation time (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constant_function_call_fresh_initial_values.expected
*/
// IEEE 1800-2023 §13.4.3: running a constant function call has no effect on
// the initial values of the variables it uses, neither for simulation nor
// for the other calls made at elaboration time; in each case the variables
// are initialized as they would be for normal simulation.
//
// bump is a static function with a static local variable acc that starts at
// 10 and adds the argument to it. It is called at elaboration for P1
// (bump(1)) and P2 (bump(2)): each call starts from acc = 10, so P1 is 11
// and P2 is 12, not 13. At simulation time acc again starts at 10, so the
// first run-time call bump(5) returns 15; as usual for a static variable
// at simulation, the second one goes on from there and returns 20.

module test_constant_function_call_fresh_initial_values;
  function int bump(int n);
    static int acc = 10;
    acc = acc + n;
    return acc;
  endfunction

  localparam int P1 = bump(1);
  localparam int P2 = bump(2);

  initial begin
    $display("elaboration: P1=%0d P2=%0d", P1, P2);
    $display("simulation: first bump(5)=%0d", bump(5));
    $display("simulation: second bump(5)=%0d", bump(5));
  end
endmodule
