/*
:name: test_free_format_layout
:description: Tokens can be laid out freely: spaces, tabs, newlines and formfeeds only separate them, while blanks and tabs inside a string literal are kept (IEEE 1800-2023 Section 5.3)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.3 5.2 5.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_free_format_layout.expected
*/
// IEEE 1800-2023 §5.2: the layout of tokens is free format; white space only
// separates tokens. §5.3: white space is spaces, tabs, newlines and formfeeds,
// and it is ignored except as a separator, but blanks and tabs in a string
// literal are significant (5.9). The declaration of total is spread over
// several lines, one statement is separated by tabs and another follows a
// formfeed. The string s holds two blanks and a tab, which count in its length.

module test_free_format_layout;
  int
    total
      =
        2
  ;
  string s = "a  b	c";

  initial begin
	total	=	total	*	21	;
    total = total
      + 0;
    $display("total=%0d", total);
    $display("len=%0d blanks at 1 and 2: %0d, tab at 4: %0d", s.len(),
             s[1] == " " && s[2] == " ", s[4] == 8'd9);
  end
endmodule
