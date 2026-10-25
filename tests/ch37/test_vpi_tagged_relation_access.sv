/*
:name: test_vpi_tagged_relation_access
:description: A relation drawn with a tag is accessed with the tag, not with the type of the target object: vpi_handle with vpiLeftRange, vpiRightRange and vpiParent for one-to-one relations, vpi_iterate and vpi_scan with vpiArgument and vpiInternalScope for one-to-many relations (IEEE 1800-2023 Section 37.4.3)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.4.3 37.12 37.16 37.17 37.42
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_tagged_relation_access.c
:expected_stdout: @test_vpi_tagged_relation_access.expected
*/
// IEEE 1800-2023 §37.4.3: a relation with a tag in the diagram is traversed
// with the tag in place of the type of the target object: vpi_handle(Tag, h)
// for a one-to-one relation and vpi_iterate(Tag, h) followed by vpi_scan for
// a one-to-many relation.
//
// One-to-one: the tags vpiLeftRange and vpiRightRange lead from the net w
// (37.16) and the variable v (37.17), both of which target an expression,
// to the bounds of their packed range, 7 and 4 for w[7:4] and 0 and 5 for
// v[0:5]; the tag vpiParent leads from the net bit w[5] to the net w
// (37.16). One-to-many: the tag vpiArgument leads from the call of $vt_tags
// (37.42) to its three arguments, w (1010, so 10), v (9) and the constant 3,
// printed sorted by value; the tag vpiInternalScope leads from the named
// block outer to the scopes it contains (37.12), the named begin first and
// the named fork second, printed sorted by name.

module test_vpi_tagged_relation_access;
  wire [7:4] w = 4'b1010;
  logic [0:5] v = 6'd9;

  initial begin : outer
    begin : first
      #1 $vt_tags(w, v, 8'd3);
    end
    fork : second
      #1;
    join
  end
endmodule
