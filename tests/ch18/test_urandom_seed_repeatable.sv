/*
:name: test_urandom_seed_repeatable
:description: $urandom with a seed starts the same sequence of random numbers every time the same seed is given, and the calls without a seed continue it (IEEE 1800-2023 Section 18.13.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.13.1 18.14.2 7.4.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_urandom_seed_repeatable.expected
*/
// IEEE 1800-2023 §18.13.1: the seed of $urandom determines the sequence of
// numbers, and the generator produces the same sequence each time the same
// seed is used; $urandom(254) gives its first number and the following calls
// without a seed the next ones of the thread's generator (18.14.2). The
// values themselves depend on the implementation, so the test compares the
// two sequences (7.4.6).

module test_urandom_seed_repeatable;
  initial begin
    int unsigned first[4], second[4];
    first[0] = $urandom(254);
    for (int i = 1; i < 4; i++) first[i] = $urandom;
    second[0] = $urandom(254);
    for (int i = 1; i < 4; i++) second[i] = $urandom;
    $display("the same seed gives the same four numbers: %0d", first == second);
  end
endmodule
