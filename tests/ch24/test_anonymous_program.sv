/*
:name: test_anonymous_program
:description: A function and a class declared in an anonymous program in the compilation unit belong to the program-wide space and are used by name from a program (IEEE 1800-2023 Section 24.6)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.6 24.3 3.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_anonymous_program.expected
*/
// IEEE 1800-2023 §24.6: an anonymous program, written as program; ...
// endprogram in the compilation unit (3.12.1), declares items of the
// program-wide space without a scope of its own, so the program
// test_anonymous_program calls the function ap_scale and uses the class
// ap_counter by their simple names. An anonymous program holds only such
// items as tasks, functions and classes, not variables (A.1.11).
// The program is not instantiated, so it is instantiated once implicitly,
// and the simulation ends when its initial procedure ends (24.3).

program;
  function automatic int ap_scale(int x);
    return 3 * x + 7;
  endfunction

  class ap_counter;
    int n;
    function void bump(int by);
      n += by;
    endfunction
  endclass
endprogram

program test_anonymous_program;
  initial begin
    static ap_counter c = new;
    c.bump(ap_scale(5));
    c.bump(1);
    $display("ap_scale(5) = %0d, counter = %0d", ap_scale(5), c.n);
  end
endprogram
