package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Tile extends FlxSprite
{
	static inline final PRESS = "press";

	static inline final CLOSE = "close";
	static inline final CLOSE_FRAME = 15;
	static inline final OPEN = "open";
	static inline final FLAG = "flag";
	static inline final FLAG_FRAME = 12;
	static inline final BOMB_EXPLODED = "bombExlpoded";
	static inline final BOMB_EXPLODED_FRAME = 10;
	static inline final BOMB_DEACTIVATED = "bombDeactivated";
	static inline final BOMB_DEACTIVATED_FRAME = 11;
	static inline final Q_MARK = "qMark";
	static inline final Q_MARK_FRAME = 13;
	static inline final Q_MARK_PRESSED = "qMarkPressed";
	static inline final Q_MARK_PRESSED_FRAME = 14;

	public var key(default, null):String;
	public var clue(default, null):Int;
	public var col(default, default):Int;
	public var row(default, default):Int;
	public var isOpen(default, default):Bool;
	public var isOver(default, default):Bool = false;
	public var symbol(default, default):Int = 0; // 0 = no symbol, 1 = flag, 2 = question mark

	private var hasBomb:Bool = false;

	public function new(_clue:Int, ?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
		
		loadGraphic("assets/images/minesweeper.png", true, 32, 32);
		clue = _clue;

		// assing frames from sprite sheet
		animation.add(CLOSE, [CLOSE_FRAME], 1, true);
		animation.add(OPEN, [_clue], 1, true); // the appropriate number matches to clue
		animation.add(PRESS, [0], 1, true);
		animation.add(BOMB_EXPLODED, [BOMB_EXPLODED_FRAME], 1, true);
		animation.add(BOMB_DEACTIVATED, [BOMB_DEACTIVATED_FRAME], 1, true);
		animation.add(FLAG, [FLAG_FRAME], 1, true);
		animation.add(Q_MARK, [Q_MARK_FRAME], 1, true);
		animation.add(Q_MARK_PRESSED, [Q_MARK_PRESSED_FRAME], 1, true);

		animation.play(CLOSE, true);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// right click mouse input
		if (FlxG.mouse.justPressedRight && isOver)
		{
			trace("right click");
			if (!isOpen)
			{
				if (symbol == 0)
				{
					symbol++; // 1
					animation.play(FLAG);
				}
				else if (symbol == 1)
				{
					symbol++; // 2
					animation.play(Q_MARK);
				}
				else
				{
					symbol = 0;
					animation.play(CLOSE);
				}
			}
		}
		// end of right click mouse input
	}

	/**
	 * Reveals/opens the tile
	 */
	public function open():Void
	{
		trace("open");
		animation.play(OPEN, true);
		isOpen = true;
	}

	/**
	 * Shows the tile as being pressed
	 */
	public function press()
	{
		if (symbol == 2)
			animation.play(Q_MARK_PRESSED, true);
		else if (!hasSymbol())
			animation.play(PRESS, true);
	}

	/**
	 * Closes/hides the tile
	 */
	public function close()
	{
		if (!hasSymbol())
			animation.play(CLOSE, true);
	}

	/**
	 * Exmplodes the tile's mine
	 */
	public function boom()
	{
		animation.play(BOMB_EXPLODED, true);
		isOpen = true;
	}

	/**
	 * Disarms the tile's mine
	 */
	public function disarm()
	{
		animation.play(BOMB_DEACTIVATED, true);
	}

	/**
	 * Checks if the tile has flag or question mark
	 * 0 = no symbol, 1 = flag, 2 = question mark
	 * @return Bool	true if has flag or question mark
	 */
	private function hasSymbol():Bool
	{
		if (symbol == 1)
		{
			animation.play(FLAG);
			return true;
		}
		else if (symbol == 2)
		{
			animation.play(Q_MARK);
			return true;
		}
		else
			return false;
	}
}
