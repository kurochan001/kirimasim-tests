/*
:name: test_vpi_block_scope_chain
:description: An unnamed begin or fork is a scope only when it directly declares something, named blocks and tasks always are; the scope of a system task call and vpiScope from each scope up to the module show which blocks are scopes, and vpiVariables of an unnamed scope gives its own variables (IEEE 1800-2023 Section 37.12)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.12 37.42 9.3.1 9.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_block_scope_chain.c
:expected_stdout: @test_vpi_block_scope_chain.expected
*/
// IEEE 1800-2023 §37.12: begin, named begin, fork, named fork and task func
// are members of the scope group. An unnamed begin or fork is a scope if, and
// only if, it directly contains a block item declaration, and a named one
// always is (detail 1). Every scope inside another has a one-to-one relation,
// vpiScope, to the scope that encloses it, and a scope gives its variables
// through vpiVariables. §37.42: a tf call has a one-to-one relation to its
// scope. Each $vt_chain call below starts at the scope of the call and follows
// vpiScope up to the module, printing each scope (with its name when it has
// one) and the variables of the first one. An unnamed block without a
// declaration is not a scope, so it is skipped: in A the scope of n1 is the
// module, while in C the scope of n2 is the unnamed begin that declares k. The
// module itself declares no variables, so the variables k and d of unnamed
// scopes would show in D or G if they were put in the module. The calls run at
// different times, so their order is fixed.

module test_vpi_block_scope_chain;
  task tk;
    begin : tb
      #8 $vt_chain("H");
    end
  endtask

  initial begin
    #1;
    begin : n1
      logic a1;
      a1 = 1'b1;
      $vt_chain("A");
    end
  end

  initial begin
    int k;
    k = 1;
    #2 $vt_chain("B");
    begin : n2
      #1 $vt_chain("C");
    end
  end

  initial begin
    #4 $vt_chain("D");
  end

  initial fork : nf
    #5 $vt_chain("E");
  join

  initial fork
    logic d;
    #6 $vt_chain("F");
  join

  initial fork
    #7 $vt_chain("G");
  join

  initial tk;
endmodule
