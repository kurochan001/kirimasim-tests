/*
:name: test_constraint_block_all_forms
:description: A constraint block holds solve-before, soft, dist, if-else, foreach, unique, an implication and disable soft together, and the values after randomize() satisfy each form (IEEE 1800-2023 Section 18.5)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5 18.5.3 18.5.5 18.5.6 18.5.7 18.5.9 18.5.13.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_block_all_forms.expected
*/
// IEEE 1800-2023 §18.5 with Syntax 18-2: a constraint block is a brace pair
// of constraint_block_items, and a constraint_expression may be a soft
// expression, a dist, a unique set, an implication to a constraint set, an
// if-else with constraint sets, a foreach over an array, and disable soft.
// Syntax 18-8 adds solve before. The block c uses all of them: solve a before
// b, soft c == 4 (later discarded), a dist with the two values 0 and 1,
// if (c == 5) b == 1 else b == 2, foreach over arr with a 0-to-9 membership,
// unique {u1, u2}, the implication a -> (c == 6), disable soft c, and
// c inside {[5:6]}. The result must have c 5 or 6, c == 6 when a is 1, b == 1
// when c is 5 and b == 2 otherwise, every arr element in 0 to 9, and
// u1 != u2. The test checks these over 100 calls.
// The 5.052 release of Verilator accepts the block and the values satisfy the
// constraints there.

class bg_obj;
  rand int a, b, c;
  rand int arr[3];
  rand int u1, u2;

  constraint c_all {
    solve a before b;
    soft c == 4;
    a dist { 0 := 1, 1 := 1 };
    if (c == 5) b == 1; else b == 2;
    foreach (arr[i]) arr[i] inside {[0:9]};
    unique { u1, u2 };
    a -> (c == 6);
    disable soft c;
    c inside {[5:6]};
  }
endclass

module test_constraint_block_all_forms;
  bg_obj o = new;
  int failures, bad_c, bad_impl, bad_b, bad_arr, bad_unique;

  initial begin
    failures = 0;
    bad_c = 0;
    bad_impl = 0;
    bad_b = 0;
    bad_arr = 0;
    bad_unique = 0;
    repeat (100) begin
      if (!o.randomize()) failures++;
      else begin
        if (o.c < 5 || o.c > 6) bad_c++;
        if (o.a == 1 && o.c != 6) bad_impl++;
        if (o.b != ((o.c == 5) ? 1 : 2)) bad_b++;
        foreach (o.arr[i]) if (o.arr[i] < 0 || o.arr[i] > 9) bad_arr++;
        if (o.u1 == o.u2) bad_unique++;
      end
    end
    $display("failures %0d, c range %0d, implication %0d",
             failures, bad_c == 0, bad_impl == 0);
    $display("b matches c %0d, arr range %0d, unique %0d",
             bad_b == 0, bad_arr == 0, bad_unique == 0);
  end
endmodule
