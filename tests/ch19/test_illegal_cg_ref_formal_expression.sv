/*
:name: test_illegal_cg_ref_formal_expression
:description: only constant expressions, enclosing-class constants, or non-ref covergroup arguments may be used as variables in a covergroup_expression, so a ref argument may not (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the coverpoint bad uses the ref argument rv of the covergroup
:expected_stderr_regex: test_illegal_cg_ref_formal_expression\.sv:32:
*/
// IEEE 1800-2023 §19.5: a covergroup_expression may use only constant
// expressions, global and instance constants that are members of the
// enclosing class, or non-ref arguments of the covergroup. Class holder
// declares the constant K and the covergroup g with a ref argument rv and an
// input argument iv. The coverpoints ck, ci and ce use the permitted forms:
// the class constant K, the non-ref input iv, and the constant expression
// 2+3. The coverpoint bad uses the ref argument rv, which is not a non-ref
// argument, and that is the one error.

module test_illegal_cg_ref_formal_expression;
  class holder;
    const int K = 3;
    int store[2] = '{1, 2};

    covergroup g (ref int rv, input int iv);
      ck: coverpoint K;
      ci: coverpoint iv;
      ce: coverpoint 2 + 3;
      bad: coverpoint rv;   // illegal: ref argument as a variable
    endgroup

    function new();
      g = new(store[0], store[1]);
    endfunction
  endclass

  initial begin
    $display("not reached");
  end
endmodule
