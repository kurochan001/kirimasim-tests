/*
:name: test_builtin_methods_unaffected_by_pli_systf
:description: A VPI application that registers $size and $len replaces the system function $size and adds $len, but the built-in methods size of a dynamic array and of a queue and len of a string keep their own results (IEEE 1800-2023 Section 5.13)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.13 36.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_builtin_methods_unaffected_by_pli_systf.c
:expected_stdout: @test_builtin_methods_unaffected_by_pli_systf.expected
*/
// IEEE 1800-2023 §5.13: built-in methods, unlike system tasks and system
// functions, cannot be redefined by users through the PLI. §36.3.2: a PLI
// application registered under the name of a built-in system function
// replaces it.
// The VPI application registers the system functions $size and $len, each of
// which returns 99. $size is the built-in array query function, so the
// registration replaces it, and $size(d) gives 99; $len is a new name and
// gives 99 too. The built-in methods with the same names are not affected:
// the dynamic array d has 3 elements, the queue q has 2 and the string s has
// 5 characters. A tool that dispatched a method call through the table of
// system functions would print 99 on the second line.
// Icarus Verilog 13.0 does not follow §5.13 here: with the application
// loaded it gives 99 for d.size() and q.size() as well. The 5.054 release
// of Verilator does not support user-defined system functions.

module test_builtin_methods_unaffected_by_pli_systf;
  int d[];
  int q[$];
  string s;

  initial begin
    d = new[3];
    q.push_back(4);
    q.push_back(5);
    s = "hello";
    $display("system functions: $size(d)=%0d $size(q)=%0d $len(s)=%0d",
             $size(d), $size(q), $len(s));
    $display("methods: d.size()=%0d q.size()=%0d s.len()=%0d", d.size(), q.size(), s.len());
  end
endmodule
