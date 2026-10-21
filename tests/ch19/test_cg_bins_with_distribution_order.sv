/*
:name: test_cg_bins_with_distribution_order
:description: For a fixed number of bins, a with clause filters the values before they are shared out, keeping repeated values and their order, unless type_option.distribute_first asks for the values to be shared out first (IEEE 1800-2023 Section 19.5.1.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1.1 19.5.1 19.7.1 19.11.1 19.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_bins_with_distribution_order.expected
*/
// IEEE 1800-2023 §19.5.1.1: by default the with clause is applied to the
// values of the range list before they are distributed to the bins, and the
// result keeps repeated values and their order; when the type option
// distribute_first is set (19.7.1), the values are distributed first. §19.5.1:
// the first B values go to the first bin and the last bin takes the rest. In
// cg_filter, b[2] gets {0} and {2, 4} from the even values 0, 2 and 4, and
// d[2] gets {3} and {1, 3} from 3, 1, 3, so a sample of 3 covers both d bins.
// In cg_distribute, [0:5] is first shared out as {0, 1, 2} and {3, 4, 5},
// and the with clause leaves {0, 2} and {4}. After each sample the test prints
// the coverage of each covergroup, that of its only coverpoint (19.11.1,
// 19.11).

module test_cg_bins_with_distribution_order;
  bit [2:0] x;

  covergroup cg_filter;
    cp: coverpoint x {
      bins b[2] = {[0:5]} with (item % 2 == 0);
      bins d[2] = {3, 1, 3, 2} with (item != 2);
    }
  endgroup

  covergroup cg_distribute;
    type_option.distribute_first = 1;
    cp: coverpoint x {
      bins b[2] = {[0:5]} with (item % 2 == 0);
    }
  endgroup

  cg_filter gf = new();
  cg_distribute gd = new();

  task automatic put(bit [2:0] v);
    x = v;
    gf.sample();
    gd.sample();
    $display("x=%0d: filtered first %.2f, distributed first %.2f", v, gf.get_inst_coverage(),
             gd.get_inst_coverage());
  endtask

  initial begin
    put(3);
    put(2);
    put(0);
    put(4);
  end
endmodule
