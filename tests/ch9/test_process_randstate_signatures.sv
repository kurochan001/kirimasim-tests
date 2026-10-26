/*
:name: test_process_randstate_signatures
:description: process srandom takes an int seed, get_randstate returns a nonempty string, and set_randstate with that string reproduces the next random value
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_randstate_signatures.expected
*/
// IEEE 1800-2023 9.7: the process class declares function void srandom(int
// seed), function string get_randstate() and function void
// set_randstate(string state). The test seeds the current process with the int
// 123, draws one value, saves the state in a string, draws a second value, and
// restores the saved string: the next value equals the second one. The string
// is queried with len(), which only a string result supports, and only
// whether it is nonempty is printed because its format is not specified. A
// tool that returns a number, or that does not restore the state, prints
// nonempty=0 or same=0.

module test_process_randstate_signatures;
  initial begin
    process p;
    string st;
    int r1, r2, r3;

    p = process::self();
    p.srandom(123);
    r1 = $urandom;
    st = p.get_randstate();
    r2 = $urandom;
    p.set_randstate(st);
    r3 = $urandom;
    $display("nonempty=%0d same=%0d", (st.len() > 0), (r2 == r3));
  end
endmodule
