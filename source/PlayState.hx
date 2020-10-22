package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import haxe.Timer;
import haxe.ds.Vector;

class PlayState extends FlxState
{
	private static inline final FIELD_W:Int = 9;
	private static inline final FIELD_H:Int = 9;
	private static inline final TOTAL_MINES:Int = 10;

	private var mineField:Vector<Vector<Int>>;
	private var tile:Tile;
	private var tiles:Vector<Vector<Tile>>;
	private var statusText:FlxText;

	private var timer:Timer = new Timer(1000);
	private var timerText:FlxText;
	private var timerCount:Int = 0;
	private var timerHasStart:Bool = false;
	private var gameOver:Bool = false;
	private var gameOverText:FlxText;

	override public function create()
	{
		super.create();

		// mine field creation
		mineField = new Vector(FIELD_H);

		for (i in 0...FIELD_H)
		{
			mineField[i] = new Vector(FIELD_W);

			for (j in 0...FIELD_W)
			{
				mineField[i][j] = 0;
			}
			trace("Row " + i + ": " + mineField[i]);
		}
		trace("Mine field: " + mineField);
		// end of mine field creation

		// placing mines
		var placedMines:Int = 0;
		var randomRow:Int, randomCol:Int;
		while (placedMines < TOTAL_MINES)
		{
			randomRow = Math.floor(Math.random() * FIELD_H);
			randomCol = Math.floor(Math.random() * FIELD_W);
			if (mineField[randomRow][randomCol] == 0)
			{
				mineField[randomRow][randomCol] = 9;
				placedMines++;
			}
		}
		trace("Mine field with mines: " + mineField);
		// end of placing mines

		// start calculating clues
		for (i in 0...FIELD_H)
		{
			for (j in 0...FIELD_W)
			{
				if (mineField[i][j] == 9)
				{
					for (ii in -1...2)
					{
						for (jj in -1...2)
						{
							if (ii != 0 || jj != 0)
							{
								if (getClue(i + ii, j + jj) != 9 && getClue(i + ii, j + jj) != -1)
								{
									mineField[i + ii][j + jj]++;
								}
							}
						}
					}
				}
			}
		}
		var debugString:String;
		trace("My complete and formatted mine field: ");
		for (i in 0...FIELD_H)
		{
			debugString = "";
			for (j in 0...FIELD_W)
			{
				debugString += mineField[i][j] + " ";
			}
			trace(debugString);
		}
		// end of calculating clues

		// tiles creation and position
		tiles = new Vector(FIELD_H);
		for (i in 0...FIELD_H)
		{
			tiles[i] = new Vector(FIELD_W);
			for (j in 0...FIELD_W)
			{
				tile = new Tile(mineField[i][j]);
				tile.x = 6 + tile.width * j;
				tile.y = 6 + tile.height * i;
				tile.col = j;
				tile.row = i;
				add(tile);
				tiles[i][j] = tile;

				FlxMouseEventManager.add(tile, onMouseDownTile, onMouseUpTile, onMouseOverTile, onMouseOutTile);
			}
		}
		// end of tiles creation and position

		// text fields
		statusText = new FlxText(0, FlxG.height - 24, FlxG.width, "", 12);
		statusText.alignment = FlxTextAlign.CENTER;
		add(statusText);

		timerText = new FlxText(tile.width * FIELD_W, 24, Math.abs(FlxG.width - tile.width * FIELD_W), "Timer: 0", 20);
		timerText.alignment = FlxTextAlign.CENTER;
		add(timerText);

		gameOverText = new FlxText(tile.width * FIELD_W, FlxG.height * .33, Math.abs(FlxG.width - tile.width * FIELD_W),
			"Total mines: " + Std.string(TOTAL_MINES) + "\n \nPress [R] to restart", 20);
		gameOverText.alignment = FlxTextAlign.CENTER;
		add(gameOverText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// restart game
		if (FlxG.keys.justPressed.R)
		{
			FlxG.resetGame();
		}

		// check for victory
		var countOpenTiles:Int = 0;
		for (i in 0...FIELD_H)
		{
			for (j in 0...FIELD_W)
			{
				if (tiles[i][j].isOpen)
					countOpenTiles++;
			}
		}

		if (countOpenTiles == FIELD_W * FIELD_H - TOTAL_MINES)
		{
			gameOver = true;
			timer.stop();
			gameOverText.text = "YOU WON!\n \nPress [R] to restart";

			for (i in 0...FIELD_H)
			{
				for (j in 0...FIELD_W)
				{
					if (mineField[i][j] == 9)
						tiles[i][j].disarm();
				}
			}
		}
		// end of check for victory
	}

	// mouse input
	private function onMouseDownTile(tile:Tile)
	{
		if (!tile.isOpen)
			tile.press();
		if (!timerHasStart)
		{
			timerHasStart = true;

			timer.run = count;
		}
	}

	private function count():Void
	{
		timerCount++;
		timerText.text = "Timer: " + Std.string(timerCount);
	}

	private function onMouseUpTile(tile:Tile)
	{
		if (!gameOver)
		{
			trace("row: " + tile.row + " col: " + tile.col + " tile clicked!");

			var row:Int = tile.row;
			var col:Int = tile.col;
			var value:Int = mineField[row][col];

			if (value < 9)
			{
				// tile.open();
				if (tile.symbol != 1)
					floodFill(row, col);
			}

			if (value == 9)
			{
				if (tile.symbol != 1)
				{
					timer.stop();
					gameOver = true;
					gameOverText.text = "BOOOOOOOOM!!!\n \nPress [R] to restart";

					for (i in 0...FIELD_H)
					{
						for (j in 0...FIELD_W)
						{
							if (mineField[i][j] == 9)
								tiles[i][j].open();
						}
					}

					tile.boom();
				}
			}
		}
	}

	private function onMouseOutTile(tile:Tile)
	{
		if (!gameOver)
		{
			tile.isOver = false;
			statusText.text = "";
			if (!tile.isOpen)
				tile.close();
		}
	}

	private function onMouseOverTile(tile:Tile)
	{
		if (!gameOver)
		{
			tile.isOver = true;

			statusText.text = "row: " + tile.row + " col: " + tile.col;
			statusText.text += tile.clue == 9 ? " clue: Bomb" : " clue: " + tile.clue; // cheat for debuging

			if (tile.symbol == 1)
				statusText.text += " [has flag]";
			else if (tile.symbol == 2)
				statusText.text += " [has question mark]";
			else
				statusText.text += " [no symbol]";

			if (FlxG.mouse.pressed)
			{
				if (!tile.isOpen)
					tile.press();
			}
		}
	} // end of mouse input

	/**
	 * Get clue from a specific tile
	 * @param row	row of minefield
	 * @param col	col of minefield
	 * @return clue as Int
	 */
	private function getClue(row:Int, col:Int):Int
	{
		if (mineField[row] == null || mineField[row][col] == null)
		{
			return -1;
		}
		else
		{
			return mineField[row][col];
		}
	}

	/** flood fill algorithm 
	 *	https://en.wikipedia.org/wiki/Flood_fill
	**/
	private function floodFill(row:Int, col:Int):Void
	{
		var tile:Tile = tiles[row][col];

		if (!tile.isOpen)
		{
			if (tile.symbol != 1)
				tile.open();

			if (mineField[row][col] == 0)
			{
				for (ii in -1...2)
				{
					for (jj in -1...2)
					{
						if (ii != 0 || jj != 0)
						{
							if (getClue(row + ii, col + jj) != 9)
							{
								if (getClue(row + ii, col + jj) != -1)
								{
									var nextTile:Tile = tiles[row + ii][col + jj];
									if (nextTile.symbol != 1) // infinite loop protection
										floodFill(row + ii, col + jj);
								}
							}
						}
					}
				}
			}
		}
	}
}
