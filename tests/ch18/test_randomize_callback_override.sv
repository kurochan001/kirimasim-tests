/*
:name: test_randomize_callback_override
:description: randomize() calls pre_randomize() and post_randomize() of the object and its enabled rand members; a derived class without them runs the base ones, and an override runs the base ones only through super (IEEE 1800-2023 Section 18.6.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.6.2 18.3 18.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randomize_callback_override.expected
*/
// IEEE 1800-2023 §18.6.2 (and §18.3): obj.randomize() calls pre_randomize()
// of obj and of each of its rand object members that is enabled, then solves,
// assigns the new values, and calls post_randomize() of the same objects. A
// derived class that does not define them runs those of its base class; one
// that overrides them runs the base ones only if it calls super, otherwise
// the base steps are skipped. The two methods are not virtual, but since
// randomize() is virtual they behave as if they were: called through a
// handle of the base class, randomize() runs the override of the object,
// while a direct call through that handle runs the method of the base class.
// If randomize() fails, pre_randomize() has run but post_randomize() is not
// called (§18.6.3).
// cbo_base counts its calls in pre/post and records v in each (v is 1 before
// and 5 after a call); each override counts in own_pre/own_post. Each line
// prints pre/post (base) and own_pre/own_post, then v seen in pre and post.
// Icarus Verilog 13.0 does not compile classes with constraints. Verilator
// 5.052 calls pre_randomize() and post_randomize() of m_on twice in one
// randomize() of the container, and calls post_randomize() after a failure.

class cbo_base;
  rand bit [3:0] v;
  int pre, post;
  bit [3:0] seen_pre, seen_post;
  constraint c { v == 4'd5; }
  function void pre_randomize();
    pre++;
    seen_pre = v;
  endfunction
  function void post_randomize();
    post++;
    seen_post = v;
  endfunction
endclass

class cbo_inherit extends cbo_base;
endclass

class cbo_no_super extends cbo_base;
  int own_pre, own_post;
  function void pre_randomize();
    own_pre++;
  endfunction
  function void post_randomize();
    own_post++;
  endfunction
endclass

class cbo_with_super extends cbo_base;
  int own_pre, own_post;
  function void pre_randomize();
    super.pre_randomize();
    own_pre++;
  endfunction
  function void post_randomize();
    super.post_randomize();
    own_post++;
  endfunction
endclass

class cbo_top;
  rand bit [3:0] t;
  rand cbo_base m_on;
  rand cbo_base m_off;
  cbo_base m_plain;
  int pre, post;
  function new();
    m_on = new;
    m_off = new;
    m_plain = new;
  endfunction
  function void pre_randomize();
    pre++;
  endfunction
  function void post_randomize();
    post++;
  endfunction
endclass

module test_randomize_callback_override;
  cbo_inherit i;
  cbo_no_super n;
  cbo_with_super s;
  cbo_base h;
  cbo_top top;
  int ok;

  function automatic string base_counts(cbo_base b);
    return $sformatf("pre=%0d post=%0d seen %0d/%0d", b.pre, b.post, b.seen_pre, b.seen_post);
  endfunction

  initial begin
    i = new;
    i.v = 4'd1;
    ok = i.randomize();
    $display("no override: ok=%0d %s", ok, base_counts(i));

    n = new;
    n.v = 4'd1;
    ok = n.randomize();
    $display("override without super: ok=%0d v=%0d %s own=%0d/%0d", ok, n.v, base_counts(n),
             n.own_pre, n.own_post);

    s = new;
    s.v = 4'd1;
    ok = s.randomize();
    $display("override with super: ok=%0d %s own=%0d/%0d", ok, base_counts(s),
             s.own_pre, s.own_post);

    h = n;
    ok = h.randomize();
    $display("through a base handle: ok=%0d %s own=%0d/%0d", ok, base_counts(n),
             n.own_pre, n.own_post);
    h.pre_randomize();
    $display("direct h.pre_randomize(): %s own=%0d/%0d", base_counts(n), n.own_pre, n.own_post);

    top = new;
    top.m_off.rand_mode(0);
    top.m_on.v = 4'd1;
    top.m_off.v = 4'd1;
    top.m_plain.v = 4'd1;
    ok = top.randomize();
    $display("container: ok=%0d top %0d/%0d", ok, top.pre, top.post);
    $display("  m_on %s", base_counts(top.m_on));
    $display("  m_off %s v=%0d", base_counts(top.m_off), top.m_off.v);
    $display("  m_plain %s v=%0d", base_counts(top.m_plain), top.m_plain.v);

    ok = i.randomize() with { v == 4'd6; };
    $display("failed call: ok=%0d v=%0d %s", ok, i.v, base_counts(i));
  end
endmodule
