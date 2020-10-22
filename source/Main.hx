package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();

		#if js
		untyped // disable right click if the target is html5
		{
			document.oncontextmenu = document.body.oncontextmenu = function()
			{
				return false;
			}
		}
		#end

		addChild(new FlxGame(512, 384, PlayState));
	}
}
