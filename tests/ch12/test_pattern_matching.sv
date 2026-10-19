/*
:name: test_pattern_matching
:description: case matches tries the patterns of tagged unions, structures, constants, wildcards and pattern identifiers in order, with &&& filters and the expression evaluated once; if with matches clauses joined by &&& and conditional expressions with matches bind identifiers for what follows (IEEE 1800-2023 Sections 12.6, 12.6.1, 12.6.2, 12.6.3)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.6 12.6.1 12.6.2 12.6.3 11.9 7.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_pattern_matching.expected
*/
// IEEE 1800-2023 §12.6: a tagged union pattern matches a value with the same
// tag whose member matches the nested pattern; a structure pattern matches if
// each listed member matches, by position or by name, with omitted members
// ignored; a constant matches an equal value; .* matches anything; .name
// matches anything and binds name to it. §12.6.1: case (e) matches evaluates
// e once and selects the first item whose pattern matches and whose &&&
// filter is true, else default. §12.6.2: in if, matches clauses and Boolean
// filters joined by &&& are tried left to right, and identifiers bound by a
// pattern can be used in the later clauses and the true branch. §12.6.3: the
// same holds for the condition of ?:. Values are built with tagged union
// expressions (§11.9) of a tagged union type (§7.3.2).

module test_pattern_matching;
  typedef union tagged {
    void Stop;
    int Go;
  } cmd_t;

  typedef union tagged {
    void None;
    int Num;
    struct { byte lo, hi; } Pair;
    cmd_t Cmd;
  } item_t;

  item_t items[8];
  int calls = 0, v;

  function automatic string describe(item_t it);
    case (it) matches
      tagged None: return "none";
      tagged Num 0: return "zero";
      tagged Num .n &&& (n < 0): return $sformatf("negative %0d", n);
      tagged Num .n: return $sformatf("number %0d", n);
      tagged Pair '{.*, 0}: return "pair with hi 0";
      tagged Pair '{hi: .h, lo: .l}: return $sformatf("pair lo %0d hi %0d", l, h);
      tagged Cmd (tagged Go .g): return $sformatf("go %0d", g);
      default: return "something else";
    endcase
  endfunction

  function automatic item_t counted(item_t it);
    calls++;
    return it;
  endfunction

  initial begin
    items[0] = tagged None;
    items[1] = tagged Num 0;
    items[2] = tagged Num (-5);
    items[3] = tagged Num 7;
    items[4] = tagged Pair '{3, 0};
    items[5] = tagged Pair '{lo: 3, hi: 4};
    items[6] = tagged Cmd (tagged Stop);
    items[7] = tagged Cmd (tagged Go 9);
    foreach (items[i]) $display("%0d: %s", i, describe(items[i]));

    case (counted(items[3])) matches
      tagged None: $display("case: none");
      tagged Num .n: $display("case: number %0d", n);
    endcase
    $display("case expression evaluated %0d time(s)", calls);

    foreach (items[i])
      if (items[i] matches tagged Cmd .c &&& c matches tagged Go .g &&& g > 5)
        $display("if: item %0d is go %0d", i, g);
      else if (items[i] matches tagged Pair '{lo: .l} &&& l == 3)
        $display("if: item %0d is a pair with lo 3", i);

    foreach (items[i]) begin
      v = items[i] matches tagged Num .n ? n * 2 : -1;
      $display("?: item %0d gives %0d", i, v);
    end
  end
endmodule
