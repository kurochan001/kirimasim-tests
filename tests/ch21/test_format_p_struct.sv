/*
:name: test_format_p_struct
:description: %p prints an unpacked structure as an assignment pattern with named members, an enum member by name, a string in quotes and a null handle as null; with white space removed the text is fixed (IEEE 1800-2023 Section 21.2.1.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.6 21.2.1 10.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_p_struct.expected
*/
// IEEE 1800-2023 §21.2.1.6: %p prints an unpacked structure as an
// assignment pattern with named elements (10.9.2). A member of an enum type
// prints as the name of its value, a string in double quotes, a null class
// handle as null, and an int as it would print unformatted. Where white space
// goes is up to the implementation, so the test removes it before printing.
// The members have different values, so no default element can shorten the
// pattern. %p of a single string prints it as an element, in quotes.
//
// With Verilator 5.052, %p prints the int as 'h5 and the enum as 'h1.

module test_format_p_struct;
  typedef enum {RED, GREEN, BLUE} color_t;
  class item;
  endclass

  typedef struct {
    int n;
    color_t c;
    string s;
    item h;
  } rec_t;

  rec_t r;
  string word = "hi";

  function automatic string squeeze(string text);
    string out = "";
    foreach (text[i])
      if (text[i] != " " && text[i] != "\t" && text[i] != "\n") out = {out, text.substr(i, i)};
    return out;
  endfunction

  initial begin
    r.n = 5;
    r.c = GREEN;
    r.s = "hi";
    r.h = null;
    $display("%s", squeeze($sformatf("%p", r)));
    $display("%s", squeeze($sformatf("%p", word)));
  end
endmodule
