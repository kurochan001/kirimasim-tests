/*
:name: test_disable_soft_size_derived_class
:description: disable soft d.size() in a derived class discards the soft size constraint of its base class, so the dynamic array is not resized, while a soft size constraint of a further derived class has higher priority than the disable and stays (IEEE 1800-2023 Section 18.5.13.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.13.2 18.5.13.1 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_soft_size_derived_class.expected
*/
// IEEE 1800-2023 §18.5.13.1: the constraints of a derived class have higher
// priority than all constraints of its superclasses. §18.5.13.2: disable soft
// on a variable, here the size of the rand dynamic array d written d.size()
// (§18.4), discards the soft constraints of lower priority in which it
// appears, even when nothing conflicts with them, and leaves those of higher
// priority. §18.4: a dynamic array whose size is constrained only by
// discarded soft constraints is not resized. Each object starts with one
// element, and the foreach constraint fixes element i to i + 1.
// - dsb_base: soft d.size() == 6 holds, so d has 6 elements, 1 to 6.
// - dsb_mid adds disable soft d.size(), of higher priority than the base
//   constraint, which is discarded, so d keeps 1 element.
// - dsb_leaf adds soft d.size() == 4, of higher priority than the disable in
//   dsb_mid, so it is kept and d has 4 elements.
// Icarus Verilog 13.0 does not support constraints. The 5.052 release
// of Verilator rejects disable soft d.size() with parentheses, and with
// disable soft d.size its randomize() of dsb_mid does not return.

class dsb_base;
  rand bit [3:0] d[];
  constraint b_size { soft d.size() == 6; }
  constraint b_el { foreach (d[i]) d[i] == 4'(i + 1); }
endclass

class dsb_mid extends dsb_base;
  constraint m_dis { disable soft d.size(); }
endclass

class dsb_leaf extends dsb_mid;
  constraint l_size { soft d.size() == 4; }
endclass

module test_disable_soft_size_derived_class;
  dsb_base b;
  dsb_mid m;
  dsb_leaf l;
  int ok;

  function automatic void show(string name, int ok, bit [3:0] d[]);
    string s = "";
    foreach (d[i]) s = {s, $sformatf(" %0d", d[i])};
    $display("%s: ok=%0d size=%0d d:%s", name, ok, d.size(), s);
  endfunction

  initial begin
    b = new;
    m = new;
    l = new;
    b.d = new[1];
    m.d = new[1];
    l.d = new[1];
    ok = b.randomize();
    show("base", ok, b.d);
    ok = m.randomize();
    show("mid", ok, m.d);
    ok = l.randomize();
    show("leaf", ok, l.d);
  end
endmodule
