/*
:name: test_program_automatic_lifetime
:description: A program declared automatic makes its subroutines automatic by default, while those of a program without the keyword are static, and an explicit lifetime on a subroutine overrides the default (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 13.4.2 6.21
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_automatic_lifetime.expected
*/
// IEEE 1800-2023 §24.3, §6.21: the lifetime in a program header is the
// default lifetime of the subroutines declared in the program. In p_auto,
// declared automatic, count gets a new n at each call, set to its default 0,
// and returns 1 each time; count_static is declared static and keeps its n.
// In p_static, a program without the keyword, count is static (13.4.2), so
// its n keeps counting up across the calls.

program automatic p_auto;
  function int count();
    int n;
    n++;
    return n;
  endfunction

  function static int count_static();
    int n;
    n++;
    return n;
  endfunction

  initial begin
    int a, b, c;
    a = count();
    b = count();
    c = count();
    $display("p_auto: count %0d %0d %0d", a, b, c);
    a = count_static();
    b = count_static();
    c = count_static();
    $display("p_auto: count_static %0d %0d %0d", a, b, c);
  end
endprogram

program p_static;
  function int count();
    int n;
    n++;
    return n;
  endfunction

  initial begin
    int a, b, c;
    #1;
    a = count();
    b = count();
    c = count();
    $display("p_static: count %0d %0d %0d", a, b, c);
  end
endprogram
