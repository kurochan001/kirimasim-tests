/*
:name: test_begin_keywords_1800_2012_additions
:description: under `begin_keywords "1800-2012" the words implements, interconnect, nettype and soft that IEEE Std 1800-2012 added are keywords, used in a class header, a net declaration, a nettype declaration and a constraint, while under "1800-2009" they are ordinary variable names (IEEE 1800-2023 Section 22.14.8)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.14.8 22.14 22.14.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_begin_keywords_1800_2012_additions.expected
*/
// IEEE 1800-2023 §22.14.8: the version specifier "1800-2012" reserves the
// keywords of the earlier versions and the four words of Table 22-6:
// implements, interconnect, nettype and soft. §22.14.7: "1800-2009" does not
// reserve them.
//   - kw2009_names, under "1800-2009", declares the four words as int
//     variables with the values 1 to 4 and prints them.
//   - Under "1800-2012" each word has its keyword role:
//       implements: kw12_square implements the interface class kw12_shape
//         (8.26), whose method called through a kw12_shape handle gives 4;
//       soft: the soft constraint v == 9 is the only constraint of
//         kw12_pick, so randomize() succeeds (1) and gives v = 9 (18.5.13);
//       nettype: kw12_nt is a user-defined nettype of logic [3:0] without a
//         resolution function (6.6.7); the net n of that type has the single
//         driver 6;
//       interconnect: the net ic connects the wire output of kw12_drive,
//         driven with 1, to the wire input of kw12_read (6.6.8), which
//         therefore sees 1.
// Each line is printed at its own time.
// Icarus Verilog 13.0 stops with a syntax error at the interface class. The
// 5.052 release of Verilator does not support nettype declarations; with n
// a wire and ic a wire it prints the expected lines.

`begin_keywords "1800-2009"
module kw2009_names;
  int implements = 1, interconnect = 2, nettype = 3, soft = 4;

  initial #1 $display("1800-2009 names: %0d %0d %0d %0d", implements, interconnect, nettype,
                      soft);
endmodule
`end_keywords

`begin_keywords "1800-2012"
interface class kw12_shape;
  pure virtual function int sides();
endclass

class kw12_square implements kw12_shape;
  virtual function int sides();
    return 4;
  endfunction
endclass

class kw12_pick;
  rand bit [3:0] v;
  constraint c_soft { soft v == 4'd9; }
endclass

module kw12_drive(output wire o);
  assign o = 1'b1;
endmodule

module kw12_read(input wire i);
endmodule

module test_begin_keywords_1800_2012_additions;
  nettype logic [3:0] kw12_nt;
  kw12_nt n;
  interconnect ic;

  assign n = 4'd6;
  kw12_drive u_drive(ic);
  kw12_read u_read(ic);

  initial begin
    kw12_square sq;
    kw12_shape shape;
    kw12_pick pick;
    int ok;

    sq = new();
    shape = sq;
    pick = new();
    ok = pick.randomize();
    #2 $display("1800-2012 keywords: sides=%0d randomize=%0d v=%0d n=%0d ic=%b", shape.sides(),
                ok, pick.v, n, u_read.i);
  end
endmodule
`end_keywords
