/*
:name: test_illegal_method_extends_followed_by_initial_in_single_declaration
:description: A second dynamic override qualifier cannot follow extends
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20 A.2.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the declaration supplies both mutually exclusive dynamic override specifiers
:expected_stderr_regex: test_illegal_method_extends_followed_by_initial_in_single_declaration\.sv:25:(?:\d+:)?[^\n]*(?i:ClassSpecifierConflict|unexpected[^\n]*initial[^\n]*expecting[^\n]*final|(?:initial|extends)[^\n]*(?:mutually exclusive|conflicting specifier))
*/
module test_illegal_method_extends_followed_by_initial_in_single_declaration;
  class parent_type;
    virtual function int value();
      return 1;
    endfunction
  endclass

  class child_type extends parent_type;
    function :extends :final int value();
      return 8;
    endfunction
    function :extends :initial int other();
      return 4;
    endfunction
  endclass
endmodule
