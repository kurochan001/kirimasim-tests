/*
:name: test_class_typedef
:description: Test: typedef class forward declaration, mutual references
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.27
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_typedef.expected
*/
// Test: typedef class forward declaration, mutual references
module test_class_typedef;

  typedef class NodeB;

  class NodeA;
    string label;
    NodeB partner;

    function new(string l);
      label = l;
      partner = null;
    endfunction

    function void set_partner(NodeB b);
      partner = b;
    endfunction

    function string partner_label();
      if (partner != null)
        return partner.label;
      else
        return "none";
    endfunction
  endclass

  class NodeB;
    string label;
    NodeA partner;

    function new(string l);
      label = l;
      partner = null;
    endfunction

    function void set_partner(NodeA a);
      partner = a;
    endfunction

    function string partner_label();
      if (partner != null)
        return partner.label;
      else
        return "none";
    endfunction
  endclass

  initial begin
    static int pass_cnt = 0;
    static int fail_cnt = 0;
    NodeA a;
    NodeB b;

    a = new("alpha");
    b = new("beta");

    // Check 1: NodeA created
    if (a.label == "alpha") begin pass_cnt++; $display("PASS: NodeA label == alpha"); end
    else begin fail_cnt++; $display("FAIL: NodeA label = %s", a.label); end

    // Check 2: NodeB created
    if (b.label == "beta") begin pass_cnt++; $display("PASS: NodeB label == beta"); end
    else begin fail_cnt++; $display("FAIL: NodeB label = %s", b.label); end

    // Check 3: unlinked partner is none
    if (a.partner_label() == "none") begin pass_cnt++; $display("PASS: unlinked partner == none"); end
    else begin fail_cnt++; $display("FAIL: unlinked = %s", a.partner_label()); end

    // Check 4: mutual link A->B
    a.set_partner(b);
    if (a.partner_label() == "beta") begin pass_cnt++; $display("PASS: A->B partner == beta"); end
    else begin fail_cnt++; $display("FAIL: A->B partner = %s", a.partner_label()); end

    // Check 5: mutual link B->A
    b.set_partner(a);
    if (b.partner_label() == "alpha") begin pass_cnt++; $display("PASS: B->A partner == alpha"); end
    else begin fail_cnt++; $display("FAIL: B->A partner = %s", b.partner_label()); end

    // Check 6: update propagates through handle
    a.label = "gamma";
    if (b.partner_label() == "gamma") begin pass_cnt++; $display("PASS: handle alias sees update"); end
    else begin fail_cnt++; $display("FAIL: after update = %s", b.partner_label()); end

    $display("Results: %0d passed, %0d failed", pass_cnt, fail_cnt);
    if (fail_cnt == 0) $display("TEST PASSED"); else $display("TEST FAILED");
    $finish;
  end

endmodule
