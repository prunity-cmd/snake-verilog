module tb_snake;
  
  reg clk;
  reg reset;
  wire gameover;
  reg [1:0] tb_dir;
  wire [1:0] grid[0:7][0:7];
  reg auto_mode;
  
  integer i,j;
  
  snake dut (
   .clk(clk),
   .reset(reset),
   .grid(grid),
   .gameover(gameover),
    .dir(tb_dir),
    .auto_mode(auto_mode)
  );
  
  //clk
  initial begin
  clk = 0;
  forever #5 clk = ~clk;
  end
  
  //reset
  initial begin
    reset = 1;
    #12 reset = 0;
  end
  
  initial begin
    auto_mode = 1;
    tb_dir = 2'b00;
   
  end
  initial begin
    #500;
    $display("timeout");
    $finish;
  end
  always @(posedge clk) begin
    #1;
    $display("time = %0t", $time);
    print_grid();
    if(dut.gameover)
      $finish;
    
  end
  
       task print_grid;
      begin
    
    $display("------------------");
    for(i=0;i<8;i++)begin
      for(j=0;j<8;j++)begin
        if(grid[i][j]==2'b00)
          $write(". ");
        else if(grid[i][j]==2'b01)
          $write("0 ");
        else if(grid[i][j]==2'b10)
          $write("x ");
      end
      $write("\n");
    end
    $display("------------------");
      end
    endtask
  
endmodule
  
