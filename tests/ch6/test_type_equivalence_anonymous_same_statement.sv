/*
:name: test_type_equivalence_anonymous_same_statement
:description: An anonymous unpacked structure, unpacked union or enum type is equivalent only for the variables of its own declaration statement: $cast between unpacked variables and try_peek on a typeless mailbox succeed within a statement and fail for a variable whose type is written with the same text in another statement, which for the enum is in a named block so that the same names can be declared again (IEEE 1800-2023 Section 6.22.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.22.2 6.24.2 15.4.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_equivalence_anonymous_same_statement.expected
*/
// IEEE 1800-2023 §6.22.2 rule b: an anonymous enum, unpacked structure or
// unpacked union type is equivalent to itself for the data objects declared
// in the same declaration statement, and to no other type. Each pair below is
// declared in one statement (s1, s2; u1, u2; e1, e2), and a third variable
// comes from a separate statement whose type is written with exactly the
// same text (s3, u3, e3): the same members in the same order, or the same
// enum names C0, C1 and C2 with the same implicit int base type and values.
// s3 and u3 are declared in the module next to the pairs. e3 cannot be
// declared there, as the names C0 to C2 would be declared twice in one scope
// (3.13, 23.9), so it is declared in the named block other_statement of the
// initial procedure: a begin-end block is a scope of its own with its own
// block name space, a data declaration may open it (9.3.1), and a name
// referenced in it is the local declaration when there is one (23.9), so in
// the block C0 is the name of the type of e3.
// Unpacked structures and unions are not singular, so $cast called as a
// function (6.24.2) checks assignment compatibility, which for two of them
// needs equivalent types, since no implicit cast is defined between them
// (6.22.3): it returns 1 and assigns, or returns 0, leaves the destination
// unchanged and reports no error. Enums are singular, and $cast between two
// enums would only check cast compatibility, so the enums are checked with
// try_peek on a typeless mailbox (15.4.8): it returns a positive value and
// copies the message when the type of the variable is equivalent to the type
// of the message, and a negative value otherwise; only the equivalent case
// copies, so a variable that fails keeps its value. The test prints the sign
// of the result, which is all that the standard fixes.
// If each statement did not keep its own type, or if anonymous types written
// alike were equivalent (types compared member by member, or enums compared
// by their names, base type and values), the casts to s3 and u3 would give 1
// and copy 3 4 and 9, and try_peek into e3 would be positive and give C2.
// Oracle checks: Icarus Verilog 13.0 does not support unpacked structures,
// and the 5.054 release of Verilator rejects the typeless mailbox as if its
// type parameter had no default, so the expected output follows the cited
// clauses alone.

module test_type_equivalence_anonymous_same_statement;
  struct {int a; int b;} s1, s2;
  struct {int a; int b;} s3;
  union {int i; bit [31:0] w;} u1, u2;
  union {int i; bit [31:0] w;} u3;
  enum {C0, C1, C2} e1, e2;
  mailbox mb;
  int r2, r3;

  function automatic string sign(int r);
    return r > 0 ? "positive" : (r < 0 ? "negative" : "zero");
  endfunction

  initial begin
    s1.a = 3;
    s1.b = 4;
    s2.a = 0;
    s2.b = 0;
    s3.a = 0;
    s3.b = 0;
    r2 = $cast(s2, s1);
    r3 = $cast(s3, s1);
    $display("struct: same statement cast=%0d s2=%0d %0d, other statement cast=%0d s3=%0d %0d",
             r2, s2.a, s2.b, r3, s3.a, s3.b);
    u1.i = 9;
    u2.i = 0;
    u3.i = 0;
    r2 = $cast(u2, u1);
    r3 = $cast(u3, u1);
    $display("union: same statement cast=%0d u2.i=%0d, other statement cast=%0d u3.i=%0d",
             r2, u2.i, r3, u3.i);
    mb = new();
    e1 = C2;
    e2 = C0;
    mb.put(e1);
    r2 = mb.try_peek(e2);
    begin : other_statement
      enum {C0, C1, C2} e3;
      e3 = C0;
      r3 = mb.try_peek(e3);
      $display("enum: same statement try_peek %s e2=%s, other statement try_peek %s e3=%s",
               sign(r2), e2.name(), sign(r3), e3.name());
    end
  end
endmodule
