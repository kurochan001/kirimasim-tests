/*
:name: test_illegal_disable_soft_user_method_size
:description: disable soft h.size() is an error when size is a function of the class of h rather than the built-in size method of an array, while disable soft h.v.size() on an array member is legal (IEEE 1800-2023 Section 18.5.13.2)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.13.2 18.4 A.1.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: disable soft h.size() puts parentheses after size, a user function of the class of h and not an array built-in method
:expected_stderr_regex: test_illegal_disable_soft_user_method_size\.sv:40:
*/
// IEEE 1800-2023 A.1.10 (Syntax 18-2, footnote 12): the empty parentheses
// after a constraint primary are allowed only when the primary is an array
// built-in method, such as size(). §18.5.13.2 with §18.4: disable soft may
// name a random variable or the size of a rand dynamic array or queue. h is a
// rand handle of class dsu_item, whose rand dynamic array v has the built-in
// size() and whose class also declares a function called size. disable soft
// h.v.size() and disable soft h.w are legal. In disable soft h.size() the
// primary names the user function size of dsu_item, which is neither a
// random variable nor an array built-in method, so the item is an error.
// Icarus Verilog 13.0 does not support disable soft, so the syntax error it
// reports on line 40 does not count. The 5.052 release of Verilator rejects
// the legal disable soft h.v.size() as well, so its syntax error on line 40
// does not count either.

class dsu_item;
  rand bit [3:0] v[];
  rand int w;
  constraint c_v { soft v.size() == 2; soft w == 1; }
  function int size();
    return v.size();
  endfunction
endclass

class dsu_obj;
  rand dsu_item h;
  constraint c_ok { disable soft h.v.size(); disable soft h.w; }
  constraint c_bad { disable soft h.size(); }   // illegal: user function size
  function new();
    h = new;
  endfunction
endclass

module test_illegal_disable_soft_user_method_size;
  dsu_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
