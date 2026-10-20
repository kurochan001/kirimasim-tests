/*
:name: test_illegal_defparam_early_resolution
:description: A defparam whose hierarchical name resolves one way during elaboration and another way once the hierarchy is complete is an error (IEEE 1800-2023 Section 23.10.4.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.10.4.2 23.10.4.1 23.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the name in the defparam would resolve to another parameter after the case generate block is elaborated
:expected_stderr_regex: test_illegal_defparam_early_resolution\.sv:38:
*/
// IEEE 1800-2023 §23.10.4.2: a defparam may have to be resolved before the
// generate constructs of its module are elaborated (23.10.4.1), and it is an
// error if its name would resolve differently once elaboration is complete. The
// top module holds an instance p of wrap, which holds an instance q of mid.
// Before the case generate of mid is elaborated, the first name p of the
// defparam is not found in mid or in wrap, so the upward search of 23.8 finds
// it in the top module and p.q.k names the parameter k of mid itself. Setting
// it to 20 selects the case item whose block is named p and holds an instance q
// of leaf; searched from mid then, p is that block and p.q.k names the k of
// leaf.

module leaf;
  parameter int k = 30;
endmodule

module mid;
  parameter int k = 10;
  case (k)
    20: begin : p
      leaf q();
    end
    default: begin : other
    end
  endcase
  defparam p.q.k = 20;   // illegal
endmodule

module wrap;
  mid q();
endmodule

module test_illegal_defparam_early_resolution;
  wrap p();
endmodule
