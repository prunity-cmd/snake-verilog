module snake(
  input clk,
  input reset,
  output reg [1:0] grid[0:7][0:7],
  output reg gameover,
  input  [1:0] dir, 
  input auto_mode
);

  integer i, j, k;
  parameter max_len = 16;
  reg [2:0] body_x[0:max_len-1];
  reg [2:0] body_y[0:max_len-1];
  reg [4:0] length;
  reg [2:0] food_x;
  reg [2:0] food_y;
  reg food_valid;
  reg overlap;
  reg [5:0] lfsr;
  reg [2:0] next_x, next_y;
  reg [1:0] ai_dir;

  always @(posedge clk or posedge reset) begin
    if (reset)
      lfsr <= 6'b101001; //linear feedback shift register, used to generate random values in hardware, it's pseudo random
    else
      lfsr <= {lfsr[4:0], lfsr[5] ^ lfsr[4]};
  end

  wire [2:0] rand_x = lfsr[2:0];
  wire [2:0] rand_y = lfsr[5:3];
  
  // self collision
  wire [1:0] final_dir;
  assign final_dir = (auto_mode) ? ai_dir : dir;

  always @(*) begin
    next_y = body_y[0];
    next_x = body_x[0];
    case (final_dir)
      2'b00: next_y = next_y + 1; 
      2'b01: next_y = next_y - 1; 
      2'b10: next_x = next_x - 1; 
      2'b11: next_x = next_x + 1; 
    endcase
  end
  
  // ai
  always @(*) begin
    ai_dir = dir; //deafult dir
    if (body_x[0] < food_x && is_safe(body_x[0] + 1, body_y[0])) begin
      ai_dir = 2'b11;
    end else if (body_x[0] > food_x && is_safe(body_x[0] - 1, body_y[0])) begin
      ai_dir = 2'b10;
    end else if (body_y[0] < food_y && is_safe(body_x[0], body_y[0] + 1)) begin
      ai_dir = 2'b00;
    end else if (body_y[0] > food_y && is_safe(body_x[0], body_y[0] - 1)) begin
      ai_dir = 2'b01;
    end
  end
  
  function is_safe;
    input [2:0] x, y;
    integer t;
    begin
      is_safe = 1;
      if (x > 7 || y > 7)
        is_safe = 0;
      for (t = 0; t < length; t = t + 1)
        if (body_x[t] == x && body_y[t] == y)
          is_safe = 0;
    end
  endfunction
      
  always @(posedge clk) begin
    if (reset) begin
      // Initialize all to prevent ghosting
      for (i = 0; i < max_len; i = i + 1) begin
        body_x[i] <= 0; 
        body_y[i] <= 0;
      end
      // Head is at index 0
      body_x[0] <= 3; 
      body_y[0] <= 2;
      body_x[1] <= 3; 
      body_y[1] <= 3;
      body_x[2] <= 3; 
      body_y[2] <= 4;
      length <= 3;
      gameover <= 0;
      food_valid <= 0;
      food_x <= 2;
      food_y <= 2;
    end else if (!gameover) begin
      // Check if snake ate food
      if (body_x[0] == food_x && body_y[0] == food_y) begin
        food_valid <= 1;
        if (length < max_len) begin
          body_x[length] <= body_x[length - 1];
          body_y[length] <= body_y[length - 1];	
        end
        length <= length + 1; // growth 
      end

      // generate food only when needed
      if (food_valid) begin
        overlap = 0;
        for (k = 0; k < length-1; k = k + 1) begin
          if (body_x[k] == rand_x && body_y[k] == rand_y)
            overlap = 1;
        end

        if (!overlap) begin
          food_x <= rand_x;
          food_y <= rand_y;
          food_valid <= 0;
        end
      end
      
      // check for boundaries before moving
      case (final_dir)
        2'b00: if (body_y[0] == 7) gameover <= 1; // right
        2'b01: if (body_y[0] == 0) gameover <= 1; // left
        2'b10: if (body_x[0] == 0) gameover <= 1; // up
        2'b11: if (body_x[0] == 7) gameover <= 1; // down
      endcase 

      for (k = 1; k < length-1; k = k + 1) begin
        if (next_x == body_x[k] && next_y == body_y[k])
          gameover <= 1;
      end

      // perform movement 
      if (!gameover) begin
        // shift body i takes value of segment ahead of it (i-1)
        for (i = length - 1; i > 0; i = i - 1) begin
          body_x[i] <= body_x[i - 1];
          body_y[i] <= body_y[i - 1];
        end
        
        // update head 
        case (final_dir)
          2'b00: body_y[0] <= body_y[0] + 1; // Move right
          2'b01: body_y[0] <= body_y[0] - 1; // Move left
          2'b10: body_x[0] <= body_x[0] - 1; // Move up
          2'b11: body_x[0] <= body_x[0] + 1; // Move down
        endcase
      end
    end
  end

  // grid display final
  always @(*) begin
    for (i = 0; i < 8; i = i + 1)
      for (j = 0; j < 8; j = j + 1)
        grid[i][j] = 2'b00;

    for (i = 0; i < max_len; i = i + 1) begin
      if (i < length) 
        grid[body_x[i]][body_y[i]] = 2'b01; // snake body
    end
    grid[food_x][food_y] = 2'b10; // food
  end

endmodule
