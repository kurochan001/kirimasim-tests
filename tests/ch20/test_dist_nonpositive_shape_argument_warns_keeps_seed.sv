/*
:name: test_dist_nonpositive_shape_argument_warns_keeps_seed
:description: $dist_exponential, $dist_poisson, $dist_chi_square, $dist_t and $dist_erlang called with a mean, degree of freedom or stage count of 0 or -1 warn, return 0 and leave the seed as it was, while the value 1 draws (IEEE 1800-2023 Section N.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2 N.2 N.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_nonpositive_shape_argument_warns_keeps_seed.expected
:expected_stdout_icarus: @test_dist_nonpositive_shape_argument_warns_keeps_seed_icarus.expected
:expected_stderr_regex: (?is)(?:\b(?:warn(?:ing)?|error)\b.*?){10}
*/
// IEEE 1800-2023 §20.14.2 asks for a mean, a degree of freedom and a stage
// count greater than 0, and §N.1 maps each of these system functions to a C
// function of §N.2, whose code defines the result. Each of
// rtl_dist_exponential, rtl_dist_poisson, rtl_dist_chi_square, rtl_dist_t and
// rtl_dist_erlang first tests that argument: when it is not greater than 0,
// the function prints a warning and returns 0 without calling its helper, so
// no uniform draw runs and the seed keeps its value. Only a positive argument
// reaches the helper, whose draws update the seed by 69069 * seed + 1.
//
// Each function is called from the seed 7 with the argument 0, with -1 and,
// as the control on the other side of the bound, with 1. The ten calls with 0
// or -1 print the value 0 and the seed 7; an implementation that let 0 or a
// negative argument reach the helper would advance the seed (and usually give
// another value). The calls with 1 draw: the values and seeds were computed
// with the C code of N.2, with the C long taken as 32 bits, as the seed and
// the arguments are 32-bit integers. The ten warnings are checked by
// :expected_stderr_regex:, which counts ten warning (or error) words in the
// messages of the run; the printed lines contain no such word. The form of a
// message, and the stream it goes to, are left to the tool: Icarus Verilog
// prints each warning as a line of its standard output just before the line
// of the call, so :expected_stdout_icarus: is the same output with those ten
// lines in their places. The values and seeds of Verilator 5.054 are those
// expected, but it prints no warning for these calls, which N.2 requires.

module test_dist_nonpositive_shape_argument_warns_keeps_seed;
  integer seed, v;

  task automatic show(string what);
    $display("%s: value %0d, seed %0d", what, v, seed);
  endtask

  initial begin
    seed = 7; v = $dist_exponential(seed, 0);  show("exponential mean 0");
    seed = 7; v = $dist_exponential(seed, -1); show("exponential mean -1");
    seed = 7; v = $dist_exponential(seed, 1);  show("exponential mean 1");
    seed = 7; v = $dist_poisson(seed, 0);      show("poisson mean 0");
    seed = 7; v = $dist_poisson(seed, -1);     show("poisson mean -1");
    seed = 7; v = $dist_poisson(seed, 1);      show("poisson mean 1");
    seed = 7; v = $dist_chi_square(seed, 0);   show("chi_square df 0");
    seed = 7; v = $dist_chi_square(seed, -1);  show("chi_square df -1");
    seed = 7; v = $dist_chi_square(seed, 1);   show("chi_square df 1");
    seed = 7; v = $dist_t(seed, 0);            show("t df 0");
    seed = 7; v = $dist_t(seed, -1);           show("t df -1");
    seed = 7; v = $dist_t(seed, 1);            show("t df 1");
    seed = 7; v = $dist_erlang(seed, 0, 10);   show("erlang k 0 mean 10");
    seed = 7; v = $dist_erlang(seed, -1, 10);  show("erlang k -1 mean 10");
    seed = 7; v = $dist_erlang(seed, 1, 10);   show("erlang k 1 mean 10");
  end
endmodule
