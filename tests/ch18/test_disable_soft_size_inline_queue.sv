/*
:name: test_disable_soft_size_inline_queue
:description: disable soft q.size() in an inline constraint block discards the class's soft size constraint even without a conflict, so the queue keeps its size; disable soft n discards a soft size constraint in which n appears; a soft size constraint after the disable stays (IEEE 1800-2023 Section 18.5.13.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.13.2 18.5.13.1 18.4 18.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_soft_size_inline_queue.expected
*/
// IEEE 1800-2023 §18.5.13.2: disable soft on a random variable, which may be
// the size of a queue written q.size() (§18.4), discards every soft
// constraint of lower priority in which that variable appears, whether or not
// it conflicts with anything. §18.5.13.1: an inline constraint block has
// higher priority than the constraints of the class, and within one block a
// later constraint has higher priority. §18.4: a queue whose size is
// constrained only by discarded soft constraints is not resized; its elements
// are still randomized. The foreach constraints fix element i to 10 + i.
// - dsq_obj alone: soft q.size() == 5 holds, so q goes from 2 to 5 elements.
// - with { disable soft q.size(); }: the class's soft size constraint is
//   discarded, so q keeps its 2 elements.
// - dsn_obj alone: soft n == 4 and soft q.size() == n both hold, so n is 4
//   and q grows from 3 to 4 elements.
// - with { disable soft n; }: n appears in soft q.size() == n, which is
//   discarded with soft n == 4, so q keeps its 3 elements (n is then
//   unconstrained and is not printed).
// - with { disable soft q.size(); soft q.size() == 1; }: the soft constraint
//   after the disable has higher priority and is kept, so q has 1 element.
// Icarus Verilog 13.0 does not support constraints. The 5.052 release
// of Verilator rejects disable soft q.size() with parentheses; with
// disable soft q.size instead it prints the first four lines, but in
// the last call it keeps the 3 elements, as if the later soft
// constraint of the inline block were discarded too.

class dsq_obj;
  rand bit [7:0] q[$];
  constraint c_size { soft q.size() == 5; }
  constraint c_el { foreach (q[i]) q[i] == 8'(10 + i); }
endclass

class dsn_obj;
  rand bit [7:0] q[$];
  rand bit [3:0] n;
  constraint c_n { soft n == 4; }
  constraint c_size { soft q.size() == n; }
  constraint c_el { foreach (q[i]) q[i] == 8'(10 + i); }
endclass

module test_disable_soft_size_inline_queue;
  dsq_obj a;
  dsn_obj b;
  int ok;

  function automatic string elems(bit [7:0] q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    a = new;
    b = new;
    a.q = '{1, 2};
    ok = a.randomize();
    $display("soft size kept: ok=%0d size=%0d q:%s", ok, a.q.size(), elems(a.q));
    a.q = '{1, 2};
    ok = a.randomize() with { disable soft q.size(); };
    $display("disable soft q.size(): ok=%0d size=%0d q:%s", ok, a.q.size(), elems(a.q));
    b.q = '{1, 2, 3};
    ok = b.randomize();
    $display("soft n kept: ok=%0d n=%0d size=%0d", ok, b.n, b.q.size());
    b.q = '{1, 2, 3};
    ok = b.randomize() with { disable soft n; };
    $display("disable soft n: ok=%0d size=%0d q:%s", ok, b.q.size(), elems(b.q));
    b.q = '{1, 2, 3};
    ok = b.randomize() with { disable soft q.size(); soft q.size() == 1; };
    $display("later soft kept: ok=%0d size=%0d q:%s", ok, b.q.size(), elems(b.q));
  end
endmodule
