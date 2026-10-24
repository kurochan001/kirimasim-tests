/*
:name: test_class_shallow_copy_covergroup_handles
:description: a shallow copy copies a property that holds a handle to a covergroup object, so both objects share that covergroup, but sets the handle of an embedded covergroup to null in the copy (IEEE 1800-2023 Section 8.12)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.12 19.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_shallow_copy_covergroup_handles.expected
*/
// IEEE 1800-2023 §8.12: a shallow copy copies object handles, including the
// handles of covergroup objects, except for embedded covergroups (§19.4):
// the handle of an embedded covergroup is set to null in the new object, and
// no new covergroup instance is created.
// cov_c has the property ext, a handle to an instance of the covergroup type
// ext_cg declared in the module, and the embedded covergroup emb_cg; its
// constructor creates both. b is a shallow copy of a: b.ext refers to the
// same covergroup object as a.ext, while b.emb_cg is null and a.emb_cg is not.
// Icarus Verilog 13.0 does not support covergroups.

module test_class_shallow_copy_covergroup_handles;
  covergroup ext_cg with function sample(int v);
    coverpoint v;
  endgroup

  class cov_c;
    int x;
    ext_cg ext;
    covergroup emb_cg;
      coverpoint x;
    endgroup
    function new();
      emb_cg = new;
      ext = new;
    endfunction
  endclass

  cov_c a, b;

  initial begin
    a = new;
    b = new a;
    $display("embedded: a.emb_cg null=%0d b.emb_cg null=%0d", a.emb_cg == null,
             b.emb_cg == null);
    $display("ordinary: b.ext same as a.ext=%0d, b.ext null=%0d", b.ext == a.ext, b.ext == null);
  end
endmodule
