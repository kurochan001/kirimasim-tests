/*
:name: test_randsequence_statement_and_production_list_elements
:description: randsequence with empty parentheses starts at the first production, with a name starts at the named one, and may hold a single production; a production list mixes production calls, code blocks with data declarations, statements and null statements or nothing, if with and without else, repeat, and case items with several expressions and default with or without a colon; rand join with and without its expression keeps the order inside each production (IEEE 1800-2023 Section 18.17, A.6.12)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17 18.17.2 18.17.3 18.17.4 18.17.5 A.6.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_statement_and_production_list_elements.expected
*/
// IEEE 1800-2023 §18.17 and A.6.12: the parentheses after randsequence are
// required and may hold the name of the top-level production. When they are
// empty, the first production is the top one, so "unnamed" logs F then S;
// with a name, generation starts there even when another production comes
// first (the third randsequence would log only m if it started at m). A
// randsequence may consist of one production.
// A production list is a sequence of elements, each a production call, a
// code block, an if-else, a repeat or a case. A code block holds data
// declarations, then statements or null statements, and may be empty.
// §18.17.2: if generates the production after the condition when it is true,
// else the one after else, and nothing when it is false and has no else.
// §18.17.4: repeat generates its production as many times as its expression
// says, which is evaluated when it is reached (n + 1 is 2), so 0 gives none.
// §18.17.3: a case item may list several expressions; the first item that
// matches wins, so 2 gives B and not C. default may be written with or
// without a colon, and with no match and no default nothing is generated.
// Every choice above depends only on variables, so the log is fixed.
// §18.17.5: rand join, with or without the real expression after it and with
// two or three productions, interleaves their items at random but keeps the
// order of the items of each production. The test prints only the length of
// the result and whether each order is kept.

module test_randsequence_statement_and_production_list_elements;
  string log;
  int n;

  function automatic int find(string s, byte ch);
    for (int i = 0; i < s.len(); i++)
      if (s[i] == ch) return i;
    return -1;
  endfunction

  function automatic bit precedes(string s, byte x, byte y);
    return find(s, x) >= 0 && find(s, y) > find(s, x);
  endfunction

  initial begin
    log = "";
    randsequence ()
      first  : { log = {log, "F"}; } second;
      second : { log = {log, "S"}; };
    endsequence
    $display("unnamed: %s", log);

    log = "";
    randsequence (only)
      only : { log = {log, "O"}; };
    endsequence
    $display("single: %s", log);

    log = "";
    n = 1;
    randsequence (top)
      m     : { log = {log, "m"}; };
      top   : { int t; string u; t = 4; u = "c"; ; log = {log, u, $sformatf("%0d ", t)}; }
              { }
              m
              if (n == 1) i else e
              if (n == 0) j else f
              if (n == 0) k
              { log = {log, " "}; }
              repeat (3) r repeat (0) z repeat (n + 1) w
              { log = {log, " "}; }
              { n = 0; } pick { n = 1; } pick { n = 2; } pick { n = 3; } pick { n = 4; } pick
              { n = 7; } pick2 { n = 8; } pick2 { n = 5; } none;
      i     : { log = {log, "i"}; };
      e     : { log = {log, "e"}; };
      j     : { log = {log, "j"}; };
      f     : { log = {log, "f"}; };
      k     : { log = {log, "k"}; };
      r     : { log = {log, "r"}; };
      z     : { log = {log, "z"}; };
      w     : { log = {log, "w"}; };
      pick  : case (n)
                0, 1    : A;
                2       : B;
                2, 3    : C;
                default : D;
              endcase;
      pick2 : case (n + 1)
                8 : G;
                default H;
              endcase;
      none  : case (n)
                1 : Z;
              endcase;
      A     : { log = {log, "A"}; };
      B     : { log = {log, "B"}; };
      C     : { log = {log, "C"}; };
      D     : { log = {log, "D"}; };
      G     : { log = {log, "G"}; };
      H     : { log = {log, "H"}; };
      Z     : { log = {log, "Z"}; };
    endsequence
    $display("elements: %s", log);

    log = "";
    randsequence (j2)
      j2 : rand join s1 s2;
      s1 : a b;
      s2 : c d;
      a  : { log = {log, "a"}; };
      b  : { log = {log, "b"}; };
      c  : { log = {log, "c"}; };
      d  : { log = {log, "d"}; };
    endsequence
    $display("rand join of 2: len=%0d a<b=%0d c<d=%0d", log.len(),
             precedes(log, "a", "b"), precedes(log, "c", "d"));

    log = "";
    randsequence (j3)
      j3 : rand join (0.5) s1 s2 s3;
      s1 : a b;
      s2 : c d;
      s3 : e;
      a  : { log = {log, "a"}; };
      b  : { log = {log, "b"}; };
      c  : { log = {log, "c"}; };
      d  : { log = {log, "d"}; };
      e  : { log = {log, "e"}; };
    endsequence
    $display("rand join of 3: len=%0d a<b=%0d c<d=%0d e=%0d", log.len(),
             precedes(log, "a", "b"), precedes(log, "c", "d"), find(log, "e") >= 0);
  end
endmodule
