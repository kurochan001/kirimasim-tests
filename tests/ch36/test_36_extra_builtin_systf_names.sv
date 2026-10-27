/*
:name: test_36_extra_builtin_systf_names
:description: Built-in system tasks and system functions, like tool-specific ones, are written with a leading $ and are called under those names (IEEE 1800-2023 Section 36.3.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.3.2 36.3 5.6.3 20.2 20.6.2 20.8.1 11.7 21.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_36_extra_builtin_systf_names.expected
*/
// IEEE 1800-2023 §36.3.2: the system tasks/functions that the language
// defines, and those that a tool adds, have names that also begin with $,
// the form that §36.3 and §5.6.3 give user system task/function names.
// The design calls a set of built-in routines under the names the standard
// gives them, each of which begins with $: the output tasks $write, $display
// and $strobe (§21.2), the system functions $clog2 (§20.8.1), $bits
// (§20.6.2), $signed and $unsigned (§11.7), and the simulation time function
// $time (§20.2). It prints their results, so each call ran under its $ name.
// A tool-specific routine also has a $ name; a portable design cannot call a
// particular one, since the standard does not define its name.

module test_36_extra_builtin_systf_names;
  int bits_of_byte, log2_of_32;

  initial begin
    bits_of_byte = $bits(byte);
    log2_of_32 = $clog2(32);
    $write("built-in names:");
    $display(" %0d %0d %0d %0d", bits_of_byte, log2_of_32,
             $signed(4'hf), $unsigned(-1));
    $strobe("strobe at %0d", $time);
  end
endmodule
