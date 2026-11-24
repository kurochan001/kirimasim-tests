/*
:name: test_current_keyword_sets_nested_under_older_version
:description: Both current keyword specifiers activate 2012 keywords inside an older keyword region
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.14.9 22.14.8
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_current_keyword_sets_nested_under_older_version.expected
*/
`begin_keywords "1800-2009"
module outer_keyword_scope;
  int soft = 6;
endmodule

`begin_keywords "1800-2017"
module keywords_2017;
  class limits;
    rand int value;
    constraint default_value { soft value == 1; }
  endclass
  int \soft  = 17;
endmodule
`end_keywords

`begin_keywords "1800-2023"
module keywords_2023;
  class limits;
    rand int value;
    constraint default_value { soft value == 1; }
  endclass
  int \soft  = 23;
endmodule
`end_keywords

module test_current_keyword_sets_nested_under_older_version;
  outer_keyword_scope outer_scope();
  keywords_2017 a();
  keywords_2023 b();
  int soft = 9;

  initial $display("outer=%0d current=%0d,%0d restored=%0d",
                   outer_scope.soft, a.\soft , b.\soft , soft);
endmodule
`end_keywords
