/*
:name: test_cg_bins_with_set_expr
:description: a with clause keeps the values of a bin's range list, or of all values of the coverpoint when its name is used, for which the expression is true before they are distributed to bins, and a set expression takes the values of an array when the covergroup is constructed (IEEE 1800-2023 Sections 19.5.1.1, 19.5.1.2)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1.1 19.5.1.2 19.5.1 19.8 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_bins_with_set_expr.expected
*/
// IEEE 1800-2023 §19.5.1.1: in bins b[] = {[0:7]} with (item % 2 == 0), the
// with clause keeps the even values before they are distributed, so there is
// one bin for each of 0, 2, 4 and 6; with the coverpoint name instead of a
// range list it applies to all values of the coverpoint. §19.5.1.2: a set
// expression gives the values of a bin as an array, evaluated when the
// covergroup instance is constructed, so changing the array afterwards
// changes nothing. With the bins below cp has 4 + 1 + 3 = 8 bins, and
// get_inst_coverage(c, t) returns the covered bins and the number of bins
// (§19.8, §19.11.1).

module test_cg_bins_with_set_expr;
  bit [3:0] x;
  int vals[$] = '{9, 11, 13};

  covergroup cg;
    cp: coverpoint x {
      bins even[] = {[0:7]} with (item % 2 == 0);
      bins fives = cp with (item % 5 == 0 && item != 0);
      bins picked[] = vals;
    }
  endgroup

  cg inst;

  task automatic put(bit [3:0] v);
    int c, t;
    x = v;
    inst.sample();
    void'(inst.cp.get_inst_coverage(c, t));
    $display("x=%0d: %0d/%0d %.2f", v, c, t, inst.cp.get_inst_coverage());
  endtask

  initial begin
    inst = new;
    vals = '{1};
    put(2);
    put(5);
    put(10);
    put(11);
    put(1);
    put(3);
    put(6);
  end
endmodule
