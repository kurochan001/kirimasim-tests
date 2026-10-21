/*
:name: test_randsequence_if_case
:description: An if production without else generates nothing when its condition is false, and a case production takes the first matching item, shares a production among several item expressions, falls back to default and generates nothing without a match and a default (IEEE 1800-2023 Section 18.17.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17.2 18.17.3 18.17
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_if_case.expected
*/
// IEEE 1800-2023 §18.17.2: an if-else production generates the production
// after the condition when it is true, else the one after else, or nothing
// when there is no else: with n set from 1 to 5 before each randsequence,
// only the even values of n are logged.
// §18.17.3: a case production compares the case expression with the item
// expressions in order and generates the production of the first match;
// items separated by commas share a production, and default is taken when
// nothing matches. Here 2 appears in two items and takes the first (disk).
// Without a matching item and without default nothing is generated.
// Every choice depends only on variables, so the logs are fixed (18.17).

module test_randsequence_if_case;
  string log;
  int n;
  int dev;

  initial begin
    log = "";
    for (n = 1; n <= 5; n++) begin
      randsequence (main)
        main  : check;
        check : if (n % 2 == 0) even;
        even  : { log = {log, $sformatf(" e%0d", n)}; };
      endsequence
    end
    $display("if without else:%s", log);

    log = "";
    for (dev = 0; dev < 7; dev++) begin
      randsequence (sel)
        sel   : case (dev)
                  0       : net;
                  1, 2    : disk;
                  2, 3    : mem;
                  default : other;
                endcase;
        net   : { log = {log, "N"}; };
        disk  : { log = {log, "D"}; };
        mem   : { log = {log, "M"}; };
        other : { log = {log, "O"}; };
      endsequence
    end
    $display("case with default: %s", log);

    log = "";
    for (dev = 0; dev < 4; dev++) begin
      randsequence (pick)
        pick : case (dev)
                 1 : hit;
               endcase;
        hit  : { log = {log, $sformatf("h%0d", dev)}; };
      endsequence
      log = {log, "."};
    end
    $display("case without default: %s", log);
  end
endmodule
