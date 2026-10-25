/*
:name: test_anonymous_program_empty_item
:description: An anonymous program inside a package declares a class and a function among empty items, a lone semicolon being a legal anonymous-program item, and a program block uses both declarations through the package scope (IEEE 1800-2023 Section 24.6)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.6 A.1.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_anonymous_program_empty_item.expected
*/
// IEEE 1800-2023 §24.6 with A.1.11: an anonymous program is the keyword
// program, a semicolon and a list of anonymous-program items, closed by
// endprogram; it may stand in a package and declares its items in the name
// space of that package without creating a new scope. An
// anonymous-program item may be a class, a function or an empty declaration,
// a lone semicolon. The declared items can be used from a program block.
//
// anon_pkg holds an anonymous program whose items are an empty declaration,
// the class counter, another empty declaration, and the function twice. The
// named program test_anonymous_program_empty_item makes a counter and calls
// its method and twice through the package scope, so the class starts at 7
// and twice(21) is 42.
// Icarus Verilog 13.0 and Verilator 5.052 do not accept an anonymous program,
// so the expected output follows the standard.

package anon_pkg;
  program ;
    ;
    class counter;
      int v = 7;
      function automatic int get();
        return v;
      endfunction
    endclass
    ;
    function automatic int twice(int x);
      return 2 * x;
    endfunction
  endprogram
endpackage : anon_pkg

program test_anonymous_program_empty_item;
  initial begin
    anon_pkg::counter c = new;
    $display("class member=%0d function=%0d", c.get(), anon_pkg::twice(21));
  end
endprogram
