  import "DPI-C" context function int run_import(input int requested, input int omit_ack);
  export "DPI-C" function run_export;

  function int run_export(input int requested);
    if (requested)
      disable worker;
    return 37;
  endfunction

  initial begin : worker
    int control;
    control = run_import(0, 0);
    $display("control returned=%0d", control);
    #1 void'(run_import(1, OMIT_ACK));
    $display("disabled caller continued");
  end

  initial begin
    #2 $display("peer continued");
  end
