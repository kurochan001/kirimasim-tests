/*
:name: test_coverage_control_scope_selection
:description: With SV_COV_HIER a module definition name sums the instances and the hierarchy below them, while with SV_COV_MODULE it sums only the items of the instances themselves, which the maxima of a definition, an instance and a leaf instance show (IEEE 1800-2023 Section 40.3.2.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.1 40.3.2.2 40.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_control_scope_selection.expected
*/
// IEEE 1800-2023 §40.3.2.1, Table 40-2: a definition name with SV_COV_HIER
// covers every instance of the module and all the hierarchy below it, a
// definition name with SV_COV_MODULE covers the instances themselves and
// excludes their children, and an instance name covers that instance, with
// the same difference. cc_mid has no items of its own except its ports and its
// child u, so the maximum of a scope is additive over disjoint parts:
// hierarchy of the definition = both instances; module of the definition =
// hierarchy of the definition minus the two leaves; hierarchy of one instance =
// module of that instance plus its leaf; module of a leaf instance = hierarchy
// of that leaf, as it has no children. These equalities hold for a tool that
// collects no toggle coverage too, where every maximum is zero. The module
// scope is named with the predefined macro `SV_COV_MODULE of §40.3.1, whose
// value Table 40-2 and the Figure 40-1 examples use.

module cc_leaf(input logic d, output logic q);
  logic held = 1'b0;

  always @(d) begin
    held = d;
    q = ~d;
  end
endmodule

module cc_mid(input logic d, output logic q);
  cc_leaf u(.d(d), .q(q));
endmodule

module test_coverage_control_scope_selection;
  logic d = 1'b0, q1, q2;

  cc_mid m1(.d(d), .q(q1));
  cc_mid m2(.d(d), .q(q2));

  int hier_def, module_def, hier_m1, module_m1, hier_m2, module_m2;
  int hier_m1_leaf, module_m1_leaf, hier_m2_leaf, module_m2_leaf, module_leaf_def;

  task automatic read_maxima;
    hier_def = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_HIER, "cc_mid");
    module_def = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_MODULE, "cc_mid");
    hier_m1 = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_HIER, m1);
    module_m1 = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_MODULE, m1);
    hier_m2 = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_HIER, m2);
    module_m2 = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_MODULE, m2);
    hier_m1_leaf = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_HIER, m1.u);
    module_m1_leaf = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_MODULE, m1.u);
    hier_m2_leaf = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_HIER, m2.u);
    module_m2_leaf = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_MODULE, m2.u);
    module_leaf_def = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_MODULE, "cc_leaf");
  endtask

  initial begin
    #1 d = 1'b1;
    #1 d = 1'b0;
    #3 read_maxima;
    $display("module scope macro is 10: %0d", `SV_COV_MODULE == 10);
    $display("hierarchy of a definition sums its instances: %0d",
             hier_def == hier_m1 + hier_m2);
    $display("module scope of a definition excludes its children: %0d",
             module_def == hier_def - hier_m1_leaf - hier_m2_leaf);
    $display("module scope of a definition sums its instances: %0d",
             module_leaf_def == module_m1_leaf + module_m2_leaf);
    $display("hierarchy of an instance includes its children: %0d",
             hier_m1 == module_m1 + hier_m1_leaf && hier_m2 == module_m2 + hier_m2_leaf);
    $display("module scope of a leaf instance equals its hierarchy: %0d",
             module_m1_leaf == hier_m1_leaf && module_m2_leaf == hier_m2_leaf);
  end
endmodule
