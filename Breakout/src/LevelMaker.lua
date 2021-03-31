LevelMaker = Class{}

function LevelMaker.createMap(Level)
	local bricks = {}

	local numRows = math.random(2,4)
	local numCols = math.random(9, 12)

    -- highest possible spawned brick color in this level; ensure we
    -- don't go above 3
    local highestTier = math.min(3, math.floor(Level / 5))

    -- highest color of the highest tier
    local highestColor = math.min(5, Level % 5 + 3)

	numBricks = 1

	local x_offset = 1
	local y_offset = 1

	-- brick width is 80
	test_brick = Brick(x, y)
	test_brick.inPlay = false

	local x = WINDOW_WIDTH/2 - numCols*(test_brick.width/2 + x_offset)
	local y = WINDOW_HEIGHT*0.1


	for row = 1, numRows do
		local skip = math.random(2) == 1 and true or false 
		local alternate = math.random(3, 4) == 3 and true or false


		local color1 = math.random(1, highestColor)
		local color2 = math.random(1, highestColor) == color1 and math.random(1, highestColor) or color2

		local tier = math.random(0, highestTier)

		if skip then 
			if numCols % 2 == 0 then 
				for col = 1, numCols - 1 do
					if col % 2 == 0 then 

						bricks[numBricks] = Brick(x + test_brick.width + x_offset, y)
						bricks[numBricks].color = color1
						bricks[numBricks].tier = tier

						if alternate and numBricks == 1 then 
							bricks[numBricks].color = color1
						elseif alternate and numBricks > 1 then 
							bricks[numBricks].color = bricks[numBricks - 1].color == color1 and color2 or color1
						end

					
						x = x + bricks[1].width*2 + x_offset*2
						numBricks = numBricks + 1
					end
				end
			else
				for col = 1, numCols do
					if col % 2 == 1 then 
						bricks[numBricks] = Brick(x, y)
						bricks[numBricks].color = color1
						bricks[numBricks].tier = tier

						if alternate and numBricks == 1 then 
							bricks[numBricks].color = color1
						elseif alternate and numBricks > 1 then 
							bricks[numBricks].color = bricks[numBricks - 1].color == color1 and color2 or color1
						end

						x = x + bricks[1].width*2 + x_offset*2
						numBricks = numBricks + 1
					end
				end
			end
			x =  WINDOW_WIDTH/2 - numCols*(test_brick.width/2 + x_offset)
			y = y + bricks[1].height + y_offset

		else
			for col = 1, numCols do
				bricks[numBricks] = Brick(x, y)
				bricks[numBricks].color = color1
				bricks[numBricks].tier = tier

				if alternate and numBricks == 1 then 
						bricks[numBricks].color = color1
				elseif alternate and numBricks > 1 then 
					bricks[numBricks].color = bricks[numBricks - 1].color == color1 and color2 or color1
				end

				x = x + bricks[1].width + x_offset
				numBricks = numBricks + 1
			end
			x =  WINDOW_WIDTH/2 - numCols*(test_brick.width/2 + x_offset)
			y = y + bricks[1].height + y_offset

		end
	end

	return bricks 
end