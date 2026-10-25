/*
:name: test_randsequence_production_heads_rules_and_weights
:description: randsequence productions with a return type, void or no type, with ports and defaults, called with positional and named arguments from calls, if, repeat and case; rules separated by | with weights written as an integral number, a parameter name with and without a package scope, and an expression, and a code block after the weight that runs after the production list of its rule; code block variables are automatic (IEEE 1800-2023 Section 18.17.7, A.6.12)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17.7 18.17.1 18.17 A.6.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_production_heads_rules_and_weights.expected
*/
// IEEE 1800-2023 §18.17.7 and A.6.12: a production may start with a data type
// or void (no type also means void) and may declare ports like a task; it is
// called like a task, with positional or named arguments, and a missing
// argument takes its default, so sum(1) returns 11 and sum(.a(2), .b(3))
// returns 5. A production called twice in a rule is read there as an array
// indexed from 1 in the order of the calls, one called once by its name.
// A production has one or more rules separated by |. §18.17.1: a rule may end
// with := and a weight, which is an integral number, a parameter name with or
// without a package scope, or an expression in parentheses; the chance of a
// rule is in proportion to its weight, so only the rule of weight 1 can be
// chosen in each production here. A code block may follow the weight; it
// belongs to the rule and runs after its production list, as the examples of
// §18.17.7 show by reading there the value returned by a production of the
// list. So "+" follows n1, after_w logs <40> from sum(30), and the "!" of a
// rule of weight 0 is never logged.
// A production called with arguments may stand in each kind of element: a
// plain call, an if-else (the else branch here takes a named argument), a
// repeat and a case item. §18.17: each code block is an automatic scope, and
// an automatic variable is initialized on each entry (6.21), so cnt logs 1
// each of the three times it is generated. Icarus Verilog 13.0 has no
// randsequence, and Verilator 5.052 does not support productions with ports
// or return values; see the comment at the end for its other differences.

package rs_weight_pkg;
  parameter int NEVER = 0;
endpackage

module test_randsequence_production_heads_rules_and_weights;
  localparam int ALWAYS = 1;
  string log;
  int n;

  initial begin
    log = "";
    n = 2;
    randsequence (main)
      int sum (int a, int b = 10) : { return a + b; };
      void tag (string s) : { log = {log, s}; };
      int seven : { return 7; };
      by_number : tag("n0") := 0 | tag("n1") := 1 { log = {log, "+"}; };
      by_name   : tag("p0") := rs_weight_pkg::NEVER | tag("p1") := ALWAYS;
      by_expr   : tag("e0") := (n - 2) { log = {log, "!"}; } | tag("e1") := (n - 1);
      after_w   : tag("x") := 0 | sum(30) := 1 { log = {log, $sformatf("<%0d>", sum)}; };
      main      : sum(1) sum(.a(2), .b(3)) seven
                  { log = {log, $sformatf("%0d,%0d,%0d ", sum[1], sum[2], seven)}; }
                  by_number by_name by_expr after_w;
    endsequence
    $display("heads and rules: %s", log);

    log = "";
    n = 1;
    randsequence ()
      top : put("a")
            if (n == 1) put("i") else put("e")
            if (n == 0) put("j") else put(.s("f"))
            repeat (2) put("r")
            case (n) 0 : put("0"); 1, 2 : put("1"); default : put("d"); endcase
            { log = {log, " "}; }
            repeat (3) cnt;
      put (string s) : { log = {log, s}; };
      cnt : { int c; c++; log = {log, $sformatf("%0d", c)}; };
    endsequence
    $display("items with arguments: %s", log);
  end
endmodule
// In a variant of this test without ports and return values, Verilator
// 5.052 also stops with an internal error on a weight with a package scope,
// runs the code block after a weight before the production list of its rule
// (+n1 instead of n1+), and keeps code block variables from one run to the
// next (123 instead of 111).
