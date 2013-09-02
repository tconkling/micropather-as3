//
// aciv

package pathtest {
import flash.utils.Dictionary;

public class MicroPather
{
    public const SOLVED :int = 0;
    public const NO_SOLUTION :int = 1;
    public const START_END_SAME :int = 2;

    public function MicroPather (graph :IGraph) {
        _graph = graph;
        _pathNodePool = new Dictionary();
    }

    public function reset () :void {
        _pathNodePool = new Dictionary();
    }

    public function solve (startState :int, endState :int) :Vector.<int> {
        //trace( "Solve" );
        _pathNodePool = new Dictionary();
        var cost:Number = 0.0;
        var path:Vector.<int> = new Vector.<int>();

        if ( startState == endState )
            return path;

        ++_frame;
        var open:Vector.<PathNode> = new Vector.<PathNode>();

        var newPathNode:PathNode = new PathNode(     _frame,
                                                    startState,                                        // node
                                                    0,                                                // cost from start
                                                    _graph.leastCostEstimate( startState, endState ),
                                                    null );
        open.push( newPathNode );

        while ( open.length )
        {
            var node:PathNode = open.pop();
            //trace( "pop", node.state, "totalCostest", node.totalCost );

            if ( node.state == endState )
            {
                //trace( "Goal reached." );
                return goalReached( node, startState, endState );
            }
            else
            {
                // We have not reached the goal - add the neighbors.
                var costs:Vector.<Number> = new Vector.<Number>();
                var neighbors:Vector.<PathNode> = new Vector.<PathNode>();

                getNodeNeighbors( node, costs, neighbors );

                for( var i:int=0; i<neighbors.length; ++i )
                {
                    if ( costs[i] == Number.MAX_VALUE ) {
                        continue;
                    }

                    var newCost:Number = node.costFromStart + costs[i];

                    var inOpen:PathNode   = neighbors[i].inOpen ? neighbors[i] : null;
                    var inClosed:PathNode = neighbors[i].inClosed ? neighbors[i] : null;
                    var inEither:PathNode = inOpen ? inOpen : inClosed;

                    //trace( "neighbor", neighbors[i].state, "inOpen", inOpen, "inClosed", inClosed );

                    if ( inEither )
                    {
                        // Is this node is in use, and the cost is not an improvement,
                        // continue on.
                        if ( inEither.costFromStart <= newCost )
                            continue;    // Do nothing. This path is not better than existing.

                        // Groovy. We have new information or improved information.
                        inEither.parent = node;
                        inEither.costFromStart = newCost;
                        inEither.estToGoal = _graph.leastCostEstimate( inEither.state, endState );
                    }

                    if ( inClosed )
                    {
                        // now open
                        inClosed.inClosed = false;
                        inClosed.inOpen = true;
                        open.push( inClosed );
                    }
                    if (!inEither)
                    {
                        var pNode:PathNode = neighbors[i];
                        pNode.parent = node;
                        pNode.costFromStart = newCost;
                        pNode.estToGoal = _graph.leastCostEstimate( pNode.state, endState ),
                        pNode.inOpen = true;
                        open.push( pNode );
                    }
                }
                open.sort( compareTotalCost );

                //trace( "Open set" );
                for( var j:int=0; j<open.length; ++j ) {
                    //-( "  ", open[j].state );
                }
            }
            node.inClosed = true;
        }
        return path;
    }

    internal function goalReached (node :PathNode, start :int, end :int) :Vector.<int> {
        // We have reached the goal.
        // How long is the path? Used to allocate the vector which is returned.
        var count:int = 1;
        var it:PathNode = node;
        while( it.parent )
        {
            ++count;
            it = it.parent;
        }
        var path:Vector.<int> = new Vector.<int>(count);
        path[0] = start;
        path[count-1] = end;
        count -= 2;

        it = node.parent;
        while( it.parent ) {
            path[count] = it.state;
            it = it.parent;
            --count;
        }

        return path;
    }

    internal function getNodeNeighbors (node :PathNode, costs :Vector.<Number>, pathNodes :Vector.<PathNode>) :void {
        var states:Vector.<int> = new Vector.<int>();
        _graph.adjacentCost( node.state, states, costs );

        for( var i:int=0; i<states.length; ++i ) {
            if ( states[i] in _pathNodePool ) {
                pathNodes[i] = _pathNodePool[ states[i] ];
            } else {
                var pn:PathNode = new PathNode( _frame, states[i], Number.MAX_VALUE, Number.MAX_VALUE, null );
                _pathNodePool[ states[i] ] = pn;
                pathNodes[i] = pn;
            }
        }
    }

    internal function compareTotalCost (x :PathNode, y :PathNode) :Number {
        // lower cost sorts to the end
        if (x.totalCost < y.totalCost) {
            return 1;
        } else if (x.totalCost > y.totalCost) {
            return -1;
        } else {
            return 0;
        }
    }

    protected var _graph :IGraph;
    protected var _frame :int;                        // incremented with every solve, used to determine

    private var _pathNodePool :Dictionary;
}
};
