/*
:name: test_cg_real_open_bin_names_merge
:description: The bins of an open array of real bins are named after their interval, with a closing bracket or parenthesis for an included or excluded high end, or after their single value, so with merge_instances an interval or a value is one type bin for all instances that have it, while intervals that differ only in the inclusion of the high end, and a value and an interval, stay apart (IEEE 1800-2023 Section 19.5.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1 19.11.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_real_open_bin_names_merge.expected
*/
// IEEE 1800-2023 §19.5.1: in an open array of real bins, binname[], each
// interval of a range is a bin named binname[low:high) when its high end is
// excluded and binname[low:high] when it is included, and each single value
// is a bin named binname[value]. With the default interval size of 1.0, a
// range wider than 1.0 is cut into intervals that include their low end and
// exclude their high end, except the last, which includes it; a range not
// wider than 1.0 is one bin that includes both ends. §19.11.3: with
// type_option.merge_instances set, the type coverage is computed over the
// union of the bins of all instances, where bins of the same name are one bin.
// The names themselves appear only in reports; the test observes them through
// that union, printing the type coverage of each coverpoint after each sample.
//
// The ranges and values come from the arguments of the instances:
//   o1: a[] of [1.0:3.0] is a[1.0:2.0) and a[2.0:3.0]; s[] has s[2.0] and
//       s[5.0:5.5]
//   o2: a[] of [2.0:4.0] is a[2.0:3.0) and a[3.0:4.0]; s[] has s[2.0] and
//       s[2.0:2.0]
//   o3: a[] of [1.0:2.0] is a[1.0:2.0]; s[] has s[2.5] and s[5.0:5.5]
//   o4: the same names as o1 for a[] and as o3 for s[]
// So rg has 5 type bins (a[2.0:3.0] of o1 and a[2.0:3.0) of o2 differ, and so
// do a[1.0:2.0) of o1 and a[1.0:2.0] of o3) and sv has 4 (s[2.0] of o2 and
// s[2.0:2.0] differ). Names that left out the inclusion of the high end
// would give rg 3 bins; bins kept apart per instance would give rg 7 and sv
// 8 bins; a value named like the interval with equal ends would give sv 3.
// Icarus Verilog 13.0 does not compile covergroups, and get_coverage of a
// coverpoint through the covergroup type is not supported by the 5.054
// release of Verilator.

module test_cg_real_open_bin_names_merge;
  real r;

  covergroup cg (real lo, real hi, real v, real p, real q);
    type_option.merge_instances = 1;
    rg: coverpoint r { bins a[] = {[lo:hi]}; }
    sv: coverpoint r { bins s[] = {v, [p:q]}; }
  endgroup

  cg o1 = new(1.0, 3.0, 2.0, 5.0, 5.5);
  cg o2 = new(2.0, 4.0, 2.0, 2.0, 2.0);
  cg o3 = new(1.0, 2.0, 2.5, 5.0, 5.5);
  cg o4 = new(1.0, 3.0, 2.5, 5.0, 5.5);

  task automatic show(string who, real v);
    $display("%s samples %.2f: rg %.2f, sv %.2f", who, v, cg::rg::get_coverage(),
             cg::sv::get_coverage());
  endtask

  initial begin
    r = 2.5;  o1.sample(); show("o1", r);
    r = 2.5;  o2.sample(); show("o2", r);
    r = 1.5;  o3.sample(); show("o3", r);
    r = 1.5;  o4.sample(); show("o4", r);
    r = 2.0;  o2.sample(); show("o2", r);
    r = 5.25; o3.sample(); show("o3", r);
    r = 2.5;  o4.sample(); show("o4", r);
    r = 3.5;  o2.sample(); show("o2", r);
  end
endmodule
