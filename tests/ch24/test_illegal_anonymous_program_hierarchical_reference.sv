/*
:name: test_illegal_anonymous_program_hierarchical_reference
:description: An anonymous program cannot contain a hierarchical reference to another program scope (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: elaboration
:lrm: 1800-2023 24.3 24.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a function of an anonymous program refers hierarchically to a variable of a named program
:expected_stderr_regex: test_illegal_anonymous_program_hierarchical_reference\.sv:21:
*/
// IEEE 1800-2023 §24.3: hierarchical references may go from one program scope
// to another, but anonymous programs shall not contain hierarchical
// references to other program scopes. §24.6: an anonymous program holds only
// subroutines and classes shared by the programs.

program;
  function int test_illegal_anonymous_program_hierarchical_reference_get();
    return test_illegal_anonymous_program_hierarchical_reference.p.level;   // illegal
  endfunction
endprogram

program test_illegal_anonymous_program_hierarchical_reference_p;
  int level = 2;
  initial $display("level=%0d", test_illegal_anonymous_program_hierarchical_reference_get());
endprogram

module test_illegal_anonymous_program_hierarchical_reference;
  test_illegal_anonymous_program_hierarchical_reference_p p();
endmodule
