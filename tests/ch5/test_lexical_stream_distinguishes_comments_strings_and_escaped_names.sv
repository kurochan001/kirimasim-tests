/*
:name: test_lexical_stream_distinguishes_comments_strings_and_escaped_names
:description: The token stream preserves comment-like text inside strings and escaped identifiers and separates adjacent operators and numbers
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.2 5.6.1 5.9.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_lexical_stream_distinguishes_comments_strings_and_escaped_names.expected
*/
module test_lexical_stream_distinguishes_comments_strings_and_escaped_names;
  logic [7:0]\if//part ;
  int \end/*note*/ ;

  initial begin
    \if//part =8'hA1^8'h03;
    \end/*note*/
           =(5/* gap */+2)*3;
    if (\end/*note*/ ==21)
      $display("escaped=%h number=%0d literal=%s", \if//part , \end/*note*/ ,
               "quote=\" // /* separator */");
  end
endmodule
