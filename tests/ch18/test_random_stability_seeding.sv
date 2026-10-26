/*
:name: test_random_stability_seeding
:description: Random stability keeps object and thread streams independent of other calls, seeds an object from the next value of the creating thread, seeds a child thread from its parent, repeats a seeded subtree, preserves earlier streams when later work is appended, and lets an object self-seed in new (IEEE 1800-2023 Sections 18.14, 18.14.1, 18.14.3 and 18.15)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.6.3 18.14 18.14.1 18.14.2 18.14.3 18.15
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_random_stability_seeding.expected
*/
// IEEE 1800-2023 §18.6.3, §18.14, §18.14.1, §18.14.3, §18.15: each object
// owns the generator its randomize() uses, seeded with the next value of the
// creating thread, so o1 and o2 repeat their values when the same creation
// order is repeated, also when their calls interleave, and srandom() reseeds
// the object generator. Drawing one value from the thread before creating an
// object changes the object's first value. A forked thread is seeded from the
// parent, so two children differ, the same order repeats, and a draw from the
// parent before the fork changes the child. A subtree that seeds its root
// itself gives the same values wherever it is called. Appending a new object
// after existing work keeps the earlier streams, while inserting one before a
// later object changes that object. An object that calls srandom() in new
// repeats its values in any context.

class rs_obj;
  rand bit [31:0] v;
endclass

class rs_self;
  rand bit [31:0] v;
  function new(int seed);
    this.srandom(seed);
  endfunction
endclass

module test_random_stability_seeding;
  rs_obj o1 = new;
  rs_obj o2 = new;
  rs_obj o3 = new;
  rs_obj o4 = new;
  rs_obj o5 = new;
  rs_obj oA = new;
  rs_obj oB = new;
  rs_obj oC = new;
  rs_obj oD = new;
  rs_obj oX = new;
  rs_self f1;
  rs_self f2;
  bit [31:0] s1[3], s2[3], r1[3], r2[3];
  bit [31:0] t1, t2, y1, y2, t3;
  bit [31:0] q1[2], q2[2];

  task automatic child(output bit [31:0] x);
    x = $urandom;
  endtask

  task automatic subtree(output bit [31:0] q[2], input int seed);
    process p;
    p = process::self();
    p.srandom(seed);
    fork
      begin q[0] = $urandom; end
      begin q[1] = $urandom; end
    join
  endtask

  initial begin
    process::self().srandom(21);
    o1 = new;
    o2 = new;
    foreach (s1[i]) begin
      void'(o1.randomize());
      s1[i] = o1.v;
      void'(o2.randomize());
      s2[i] = o2.v;
    end
    process::self().srandom(21);
    o3 = new;
    o4 = new;
    foreach (r1[i]) begin
      void'(o3.randomize());
      r1[i] = o3.v;
      void'(o4.randomize());
      r2[i] = o4.v;
    end
    $display("object stability: same creation order repeats %0d, two objects differ %0d",
             s1 == r1 && s2 == r2, s1[0] != s2[0]);

    process::self().srandom(21);
    void'($urandom);
    o5 = new;
    void'(o5.randomize());
    $display("object seed from the thread: one draw before new changes it %0d",
             o5.v != s1[0]);

    process::self().srandom(31);
    fork child(t1); join
    fork child(t2); join
    process::self().srandom(31);
    fork child(y1); join
    fork child(y2); join
    $display("thread seeding: same order repeats %0d, children differ %0d",
             t1 == y1 && t2 == y2, t1 != t2);
    process::self().srandom(31);
    void'($urandom);
    fork child(t3); join
    $display("parent draw before the fork changes the child %0d", t3 != t1);

    process::self().srandom(1);
    subtree(q1, 77);
    process::self().srandom(2);
    subtree(q2, 77);
    $display("a subtree seeded at its root repeats %0d", q1 == q2);

    process::self().srandom(41);
    oA = new;
    foreach (s1[i]) begin
      void'(oA.randomize());
      r1[i] = oA.v;
    end
    oC = new;
    foreach (s2[i]) begin
      void'(oC.randomize());
      r2[i] = oC.v;
    end
    process::self().srandom(41);
    oB = new;
    foreach (s1[i]) begin
      void'(oB.randomize());
      s1[i] = oB.v;
    end
    oX = new;
    void'($urandom);
    oD = new;
    foreach (s2[i]) begin
      void'(oD.randomize());
      s2[i] = oD.v;
    end
    $display("creation order: earlier stream kept %0d, inserted creation changes later %0d",
             r1 == s1, r2 != s2);

    f1 = new(55);
    f2 = new(55);
    foreach (s1[i]) begin
      void'(f1.randomize());
      r1[i] = f1.v;
      void'(f2.randomize());
      r2[i] = f2.v;
    end
    $display("self-seeded objects: same seed repeats %0d", r1 == r2);
  end
endmodule
