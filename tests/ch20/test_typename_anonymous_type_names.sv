/*
:name: test_typename_anonymous_type_names
:description: $typename gives an anonymous struct, union or enum a name made by the system, so variables of one anonymous declaration give the same string while another declaration with the same members or named constants gives a different string (IEEE 1800-2023 Section 20.6.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typename_anonymous_type_names.expected
*/
// IEEE 1800-2023 §20.6.1: to build the string that $typename returns, the
// system creates names for anonymous structs, unions and enums (step c), much
// as type matching (6.22.1) tells types apart. An anonymous struct, union
// or enum type matches only itself among the data objects of the same
// declaration (6.22.1 c), so s1 and s2 have one type and s3, declared
// separately with the same members, another; u1, u2 and u3 likewise. The
// strings of s1 and s3 differ only in the created names, so they are not
// equal, while those of s1 and s2 are. Two anonymous enums with the same
// named constants cannot share a scope, so the named blocks first and second
// each declare one; their strings would be equal without the created names,
// since the name of an anonymous type is the only place for a scope prefix
// (step f). The test prints only whether two strings are equal: the form of
// the created names is left to the tool.
// The 5.054 release of Verilator prints the expected output; Icarus Verilog
// 13.0 does not compile unpacked structs.

module test_typename_anonymous_type_names;
  struct { int f; byte g; } s1, s2;
  struct { int f; byte g; } s3;
  union packed { int f; bit [31:0] g; } u1, u2;
  union packed { int f; bit [31:0] g; } u3;
  string e_first_a, e_first_b, e_second;

  initial begin : first
    enum { P, Q } ea, eb;
    e_first_a = $typename(ea);
    e_first_b = $typename(eb);
  end

  initial begin : second
    enum { P, Q } ec;
    e_second = $typename(ec);
  end

  initial begin
    #1;
    $display("struct, one declaration: equal %0d", $typename(s1) == $typename(s2));
    $display("struct, two declarations: equal %0d", $typename(s1) == $typename(s3));
    $display("union, one declaration: equal %0d", $typename(u1) == $typename(u2));
    $display("union, two declarations: equal %0d", $typename(u1) == $typename(u3));
    $display("enum, one declaration: equal %0d", e_first_a == e_first_b);
    $display("enum, two declarations: equal %0d", e_first_a == e_second);
  end
endmodule
