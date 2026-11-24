typedef bit [3:0] item;
int local_value = 43;

module unit_mode_provider;
  task bump();
    $unit::local_value++;
  endtask

  function int current();
    return $unit::local_value;
  endfunction
endmodule
