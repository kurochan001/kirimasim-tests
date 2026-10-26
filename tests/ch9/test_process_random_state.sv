/*
:name: test_process_random_state
:description: std::process srandom(seed) seeds the random state of the process, so the same seed gives the same sequence again, get_randstate() returns that state as a string, and set_randstate() with that string makes the following values repeat (IEEE 1800-2023 Section 9.7, G.6, 18.13.3 to 18.13.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7 18.13.3 18.13.4 18.13.5 G.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_random_state.expected
*/
// IEEE 1800-2023 §9.7 and G.6: the process class has srandom(int),
// get_randstate() returning a string, and set_randstate(string).
// §18.13.3: srandom() seeds the RNG associated with the process. §18.13.1:
// the generator gives the same sequence whenever it is given the same seed.
// §18.13.4: get_randstate() retrieves the internal state of that RNG, a string
// of unspecified length and format. §18.13.5: set_randstate() sets the state
// from such a string, so the values that follow repeat those that followed the
// same state before.
//
// The test seeds its own process twice with 17 and compares the two values
// $urandom returns, which come from the process RNG (18.14.1). It then saves
// the state, draws two values, restores the state and draws two values again;
// both pairs must agree. No value of the generator is printed, since the
// standard does not fix the numbers themselves. The space before the
// parenthesis of srandom is insignificant in SystemVerilog and keeps the call
// from being read as a randomization call by some parsers.

module test_process_random_state;
  initial begin
    std::process here = std::process::self();
    string state;
    int first_a, first_b, second_a, second_b;

    here.srandom (17);
    first_a = $urandom;
    here.srandom (17);
    first_b = $urandom;
    $display("the same seed repeats the sequence %0d", first_a == first_b);

    state = here.get_randstate();
    first_a = $urandom;
    first_b = $urandom;
    here.set_randstate(state);
    second_a = $urandom;
    second_b = $urandom;
    $display("the saved state repeats both values %0d",
             first_a == second_a && first_b == second_b);
    $finish;
  end
endmodule
