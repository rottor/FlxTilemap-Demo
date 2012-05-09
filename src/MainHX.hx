package ;
import org.flixel.FlxGame;

class MainHX extends FlxGame
{
    public function new()
    {
        super(400, 300, MenuState, 1, 20, 20);
    }
}
