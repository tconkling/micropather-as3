/*
Copyright (c) 2000-2005 Lee Thomason (www.grinninglizard.com)

Grinning Lizard Utilities.

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any
damages arising from the use of this software.

Permission is granted to anyone to use this software for any
purpose, including commercial applications, and to alter it and
redistribute it freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must
not claim that you wrote the original software. If you use this
software in a product, an acknowledgment in the product documentation
would be appreciated but is not required.

2. Altered source versions must be plainly marked as such, and
must not be misrepresented as being the original software.

3. This notice may not be removed or altered from any source
distribution.
*/

package pathtest {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import flash.system.System;
    import flash.text.TextField;


    public class Dungeon extends Sprite implements IGraph {

        private const MAPX:int = 30;
        private const MAPY:int = 10;
        private const gMap:String =
            "     |      |                |" +
            "     |      |----+    |      +" +
            "---+ +---DD-+      +--+--+    " +
            "   |                     +-- +" +
            "        +----+  +---+         " +
            "---+ +  D    D            |   " +
            "   | |  +----+    +----+  +--+" +
            "   D |            |    |      " +
            "   | +-------+  +-+    |--+   " +
            "---+                   |     +";

        private var children:Vector.<Sprite>;

        private var selected:Sprite;
        private var player:Sprite;
        private var path:Sprite;
        private var pather:MicroPather;
        private var textField:TextField;

        public var playerX:int = 0;
        public var playerY:int = 0;
        public var doorsOpen:Boolean = false;



        public function Dungeon() {
            this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        }

        public function addedToStage (e :Event) :void {
            trace( "Dungeon constructing." );

            this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveEvent);
            this.addEventListener(MouseEvent.CLICK, onMouseClickEvent);

            children = new Vector.<Sprite>();

            for( var j:int=0; j<MAPY; ++j ) {
                for( var i:int=0; i<MAPX; ++i ) {
                    var index:int = Encode( i, j );
                    children[index] = new Sprite();
                    this.addChild( children[index] );
                    //dstates.push( new DState( i, j ) );
                }
            }
            player = new Sprite();
            player.graphics.beginFill( 0x00ff00 );
            player.graphics.drawCircle( 0.5*stage.stageWidth/MAPX, 0.5*stage.stageHeight/MAPY, 10 );
            this.addChild( player );

            path = new Sprite();
            this.addChild( path );
            pather = new MicroPather( this );

            textField = new TextField();
            addChild(textField);

            Draw();
        }

//        public function Index( x:int, y:int ):int
//    /    {
//            return y*MAPX + x;
//        }

        public function Draw():void {
            for( var j:int=0; j<MAPY; ++j ) {
                for( var i:int=0; i<MAPX; ++i ) {
                    var c:uint = 0xaaaaaa;

                    var t:int = Passable( i, j );
                    if ( t == 0 ) {
                        c = 0x000000;
                    }
                    else if ( t == 2 ) {
                        if ( doorsOpen )
                            c = 0xf39739;
                        else
                            c = 0xa57c52;
                    }
                    var s:Sprite = children[j*MAPX+i];
                    s.graphics.clear();
                    s.graphics.beginFill( c );
                    s.graphics.drawRect( 0, 0, stage.stageWidth/MAPX, stage.stageHeight/MAPY );
                    s.x = stage.stageWidth/MAPX*i;
                    s.y = stage.stageHeight/MAPY*j;
                }
            }
        }

        public function Encode( x:int, y:int ):int
        {
            return y*MAPX+x;
        }

        public function Decode( state:int ):Point {
            var y:int = state / MAPX;
            var x:int = state - y*MAPX;
            return new Point( x, y );
        }

        public function onMouseMoveEvent(event:MouseEvent):void
        {
            var dx:Number = stage.stageWidth/MAPX;
            var dy:Number = stage.stageHeight/MAPY;
            var x:int = event.stageX / dx;
            var y:int = event.stageY / dy;
            var index:int = y*MAPX+x;

            var ct:ColorTransform = new ColorTransform();
            //ct.blueOffset = 100;
            //ct.redOffset = 100;
            ct.greenOffset = 100;
            if ( selected )
                selected.transform.colorTransform = new ColorTransform();
            children[index].transform.colorTransform = ct;
            selected = children[index];
        }

        public function onMouseClickEvent(event:MouseEvent):void
        {
            var dx:Number = stage.stageWidth/MAPX;
            var dy:Number = stage.stageHeight/MAPY;
            var dx2:Number = dx*0.5;
            var dy2:Number = dy*0.5;
            var x:int = event.stageX / dx;
            var y:int = event.stageY / dy;
            var passable:int = Passable( x, y );

            if ( passable == 1 ) {

                var solution:Vector.<int> = pather.solve( Encode( playerX, playerY ),
                                                        Encode( x, y ) );
                trace( "Solution length=", solution.length );

                path.graphics.clear();
                path.graphics.lineStyle( 2, 0xff0000 );

                path.graphics.moveTo( playerX*dx+dx2, playerY*dy+dy2 );
                for( var i:int=1; i<solution.length; ++i ) {
                    var p:Point = Decode( solution[i] );
                    path.graphics.lineTo( p.x*dx+dx2, p.y*dy+dy2 );
                }

                if ( solution.length > 0 ) {
                    playerX = x;
                    playerY = y;
                    player.x = playerX*dx;
                    player.y = playerY*dy;
                }
            }
            else if ( passable == 2 ) {
                // door!
                doorsOpen = !doorsOpen;
                Draw();
            }

            textField.text = "Memory=" + System.totalMemory/1024 + "k";
        }


        public function Passable( nx:int, ny:int ):int
        {
            if ( nx >= 0 && nx < MAPX && ny >= 0 && ny < MAPY )
            {
                var index:int = ny*MAPX+nx;
                var c:String = gMap.charAt( index );

                if ( c == ' ' )
                    return 1;
                else if ( c == 'D' )
                    return 2;
            }
            return 0;
        }

        public function leastCostEstimate( stateStart:int, stateEnd:int ):Number
        {
            var d0:Point = Decode( stateStart );
            var d1:Point = Decode( stateEnd );
            var dx:int = d0.x - d1.x;
            var dy:int = d0.y - d1.y;

            return Math.sqrt( dx*dx + dy*dy );
        }

        public function adjacentCost( node:int, states:Vector.<int>, costs:Vector.<Number> ):void
        {
            var dx:Array = [ 1, 1, 0, -1, -1, -1, 0, 1 ];
            var dy:Array = [ 0, 1, 1, 1, 0, -1, -1, -1 ];
            var cost:Array = [ 1.0, 1.41, 1.0, 1.41, 1.0, 1.41, 1.0, 1.41 ];

            var state:Point = Decode( node );

            for( var i:int=0; i<8; ++i ) {
                var nx:int = state.x + dx[i];
                var ny:int = state.y + dy[i];

                var pass:int = Passable( nx, ny );
                if ( pass > 0 ) {
                    if ( pass == 1 || doorsOpen )
                    {
                        // Normal floor
                        //var index:int = ny*MAPX+nx;
                        states.push( Encode( nx, ny ) );
                        costs.push( cost[i] );
                    }
                }
            }
        }
    }
}
