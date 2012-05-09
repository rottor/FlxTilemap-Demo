package ;
import nme.display.Bitmap;
import nme.media.Sound;
import nme.Assets;

/**
 * ...
 * @author YuriK
 */

class FlxAssets 
{
	public static var auto_tiles:Class <Bitmap> = AutoTiles;
	public static var alt_tiles:Class <Bitmap> = AltTiles;
	public static var empty_tiles:Class <Bitmap> = EmptyTiles;
	public static var spaceman:Class <Bitmap> = SpaceMan;
}

class AutoTiles extends Bitmap {
	public function new() { super(Assets.getBitmapData("assets/auto_tiles.png")); }
}

class AltTiles extends Bitmap {
    public function new() { super(Assets.getBitmapData("assets/alt_tiles.png")); }
}

class EmptyTiles extends Bitmap {
    public function new() { super(Assets.getBitmapData("assets/empty_tiles.png")); }
}

class SpaceMan extends Bitmap {
    public function new() { super(Assets.getBitmapData("assets/spaceman.png")); }
}

