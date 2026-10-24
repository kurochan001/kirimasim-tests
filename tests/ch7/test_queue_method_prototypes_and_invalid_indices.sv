/*
:name: test_queue_method_prototypes_and_invalid_indices
:description: queue methods follow their prototypes: size() returns int, insert() and delete() take an integer index and ignore an index that is negative, too large or has x bits, insert(), push_front() and push_back() convert the item to the element type, and pop_front() and pop_back() return the element type (IEEE 1800-2023 Section 7.10.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2.2 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.5 7.10.2.6 7.10.2.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_queue_method_prototypes_and_invalid_indices.expected
*/
// IEEE 1800-2023 §7.10.2.1: function int size(). §7.10.2.2: function void
// insert(input integer index, input element_t item); an index with x or z
// bits, below 0 or above the size leaves the queue unchanged, and an index
// equal to the size inserts at the end. §7.10.2.3: function void delete(
// [input integer index]); without an index it empties the queue, and an index
// with x or z bits, below 0 or not below the size leaves it unchanged.
// §7.10.2.4 and §7.10.2.5: pop_front() and pop_back() take no argument and
// return element_t. §7.10.2.6 and §7.10.2.7: push_front(input element_t item)
// and push_back(input element_t item) return void and put the item at the
// front or back.
// qb is a queue of byte, so items are converted to byte (300 becomes 44,
// 9'h1fe becomes -2, 200 becomes -56) and popped bytes widen to int with their
// sign; qn is a queue of bit [3:0], whose popped 4'hf widens to 15. The index
// 64'h1_0000_0002 is converted to the 32-bit integer 2. The test makes no
// assumption about the optional warnings.

module test_queue_method_prototypes_and_invalid_indices;
  byte qb[$] = '{1, 2, 3};
  bit [3:0] qn[$] = '{4'hf, 4'h1};
  int qe[$];
  int v;
  integer bad = 'x;

  task automatic show(string label);
    string s = $sformatf("size=%0d:", qb.size());
    foreach (qb[i]) s = {s, $sformatf(" %0d", qb[i])};
    $display("%s %s", label, s);
  endtask

  initial begin
    $display("size: %0d bits=%0d empty size-1<0=%0d", qb.size(), $bits(qb.size()),
             qe.size() - 1 < 0);
    qb.insert(1, 300);
    show("insert(1, 300):");
    qb.insert(4, -1);
    show("insert(size, -1):");
    qb.insert(-1, 9);
    qb.insert(6, 9);
    qb.insert(bad, 9);
    show("invalid inserts:");
    qb.insert(64'h1_0000_0002, 7);
    show("insert(64'h1_0000_0002, 7):");
    qb.delete(-1);
    qb.delete(6);
    qb.delete(bad);
    show("invalid deletes:");
    qb.delete(5);
    show("delete(5):");
    qb.push_front(9'h1fe);
    show("push_front(9'h1fe):");
    v = qb.pop_front();
    $display("pop_front -> %0d", v);
    qb.push_back(200);
    show("push_back(200):");
    v = qb.pop_back();
    $display("pop_back -> %0d", v);
    v = qn.pop_front();
    $display("bit [3:0] pop_front -> %0d, left %0d", v, qn.size());
    qb.delete();
    show("delete():");
  end
endmodule
