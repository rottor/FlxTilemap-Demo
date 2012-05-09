package ;
import nme.installer.Assets;
import nme.display.Bitmap;
import org.flixel.FlxSprite;
import org.flixel.FlxText;
import org.flixel.FlxButton;
import org.flixel.FlxObject;
import org.flixel.FlxTilemap;
import org.flixel.FlxState;
import org.flixel.FlxG;

class PlayState extends FlxState
{
    // Some static constants for the size of the tilemap tiles
    inline static var TILE_WIDTH  :Int = 16;
    inline static var TILE_HEIGHT :Int = 16;

    // The FlxTilemap we're using
    var collisionMap:FlxTilemap;

    // Box to show the user where they're placing stuff
    var highlightBox:FlxObject;

    // Player modified from "Mode" demo
    private var player:FlxSprite;

    // Some interface buttons and text
    var autoAltBtn:FlxButton;
    var resetBtn  :FlxButton;
    var quitBtn   :FlxButton;
    var helperTxt :FlxText;

    override public function create():Void
    {
        FlxG.framerate = 50;
        FlxG.flashFramerate = 50;

        // Creates a new tilemap with no arguments
        collisionMap = new FlxTilemap();

        // Initializes the map using the generated string, the tile images, and the tile size
        collisionMap.loadMap(Assets.getText('assets/default_auto.txt'), FlxAssets.auto_tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
        add(collisionMap);

        highlightBox = new FlxObject(0, 0, TILE_WIDTH, TILE_HEIGHT);

        setupPlayer();

        // When switching between modes here, the map is reloaded with it's own data, so the positions of tiles are kept the same
        // Notice that different tilesets are used when the auto mode is switched
        autoAltBtn = new FlxButton(4, FlxG.height - 24, "AUTO", function()
        {
            switch(collisionMap.auto)
            {
                case FlxTilemap.AUTO:
                    collisionMap.loadMap(FlxTilemap.arrayToCSV(collisionMap.getData(true), collisionMap.widthInTiles),
                    FlxAssets.alt_tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.ALT);
                    autoAltBtn.label.text = "ALT";

                case FlxTilemap.ALT:
                    collisionMap.loadMap(FlxTilemap.arrayToCSV(collisionMap.getData(true), collisionMap.widthInTiles),
                    FlxAssets.empty_tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.OFF);
                    autoAltBtn.label.text = "OFF";

                case FlxTilemap.OFF:
                    collisionMap.loadMap(FlxTilemap.arrayToCSV(collisionMap.getData(true), collisionMap.widthInTiles),
                    FlxAssets.auto_tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
                    autoAltBtn.label.text = "AUTO";
            }
        });
        add(autoAltBtn);

        resetBtn = new FlxButton(8 + autoAltBtn.width, FlxG.height - 24, "Reset", function()
        {
            switch(collisionMap.auto)
            {
                case FlxTilemap.AUTO:
                collisionMap.loadMap(Assets.getText('assets/default_auto.txt'), FlxAssets.auto_tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
                player.x = 64;
                player.y = 220;

                case FlxTilemap.ALT:
                collisionMap.loadMap(Assets.getText('assets/default_alt.txt'), FlxAssets.alt_tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.ALT);
                player.x = 64;
                player.y = 128;

                case FlxTilemap.OFF:
                collisionMap.loadMap(Assets.getText('assets/default_empty.txt'), FlxAssets.empty_tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.OFF);
                player.x = 64;
                player.y = 64;
            }
        });
        add(resetBtn);

        quitBtn = new FlxButton(FlxG.width - resetBtn.width - 4, FlxG.height - 24, "Quit"
            , function() { FlxG.fade(0xff000000, 0.22, true,
                            function() { FlxG.switchState(new MenuState());} );
            } );
        add(quitBtn);

        helperTxt = new FlxText(12 + autoAltBtn.width*2, FlxG.height - 30, 150, "Click to place tiles\nShift-Click to remove tiles\nArrow keys to move");
        add(helperTxt);
    }

    private function setupPlayer()
    {
        player = new FlxSprite(64, 220);
        player.loadGraphic(FlxAssets.spaceman, true, true, 16);

        //bounding box tweaks
        player.width = 14;
        player.height = 14;
        player.offset.x = 1;
        player.offset.y = 1;

        //basic player physics
        player.drag.x = 640;
        player.acceleration.y = 420;
        player.maxVelocity.x = 80;
        player.maxVelocity.y = 200;

        //animations
        player.addAnimation("idle", [0]);
        player.addAnimation("run", [1, 2, 3, 0], 12);
        player.addAnimation("jump", [4]);

        add(player);
    }

    override public function update()
    {
        // Tilemaps can be collided just like any other FlxObject, and flixel
        // automatically collides each individual tile with the object.
        FlxG.collide(player, collisionMap);

        highlightBox.x = Math.floor(FlxG.mouse.x / TILE_WIDTH) * TILE_WIDTH;
        highlightBox.y = Math.floor(FlxG.mouse.y / TILE_HEIGHT) * TILE_HEIGHT;

        if (FlxG.mouse.pressed())
        {
            // FlxTilemaps can be manually edited at runtime as well.
            // Setting a tile to 0 removes it, and setting it to anything else will place a tile.
            // If auto map is on, the map will automatically update all surrounding tiles.
            collisionMap.setTile(Std.int(FlxG.mouse.x / TILE_WIDTH), Std.int(FlxG.mouse.y / TILE_HEIGHT), FlxG.keys.SHIFT?0:1);
        }

        updatePlayer();
        super.update();
    }

    public override function draw()
    {
        super.draw();
        highlightBox.drawDebug();
    }

    private function updatePlayer()
    {
        wrap(player);

        //MOVEMENT
        player.acceleration.x = 0;
        if(FlxG.keys.LEFT)
        {
            player.facing = FlxObject.LEFT;
            player.acceleration.x -= player.drag.x;
        }
        else if(FlxG.keys.RIGHT)
        {
            player.facing = FlxObject.RIGHT;
            player.acceleration.x += player.drag.x;
        }
        if(FlxG.keys.justPressed("UP") && player.velocity.y == 0)
        {
            player.y -= 1;
            player.velocity.y = -200;
        }

        //ANIMATION
        if(player.velocity.y != 0)
        {
            player.play("jump");
        }
        else if(player.velocity.x == 0)
        {
            player.play("idle");
        }
        else
        {
            player.play("run");
        }
    }

    private function wrap(obj:FlxObject)
    {
        obj.x = (obj.x + obj.width / 2 + FlxG.width) % FlxG.width - obj.width / 2;
        obj.y = (obj.y + obj.height / 2) % FlxG.height - obj.height / 2;
    }
}
