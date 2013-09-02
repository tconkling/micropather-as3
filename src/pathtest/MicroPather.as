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

    public function solve (startState :int, endState :int, outPath :Vector.<int> = null) :int {
        _pathNodePool = new Dictionary();

        if (startState == endState) {
            return START_END_SAME;
        }

        ++_frame;
        var open :Vector.<PathNode> = new Vector.<PathNode>();

        var newPathNode :PathNode = new PathNode(_frame, startState, 0,
            _graph.leastCostEstimate(startState, endState), null);
        open.push(newPathNode);

        while (open.length > 0) {
            var node:PathNode = open.pop();
            //trace( "pop", node.state, "totalCostest", node.totalCost );

            if (node.state == endState) {
                //trace( "Goal reached." );
                goalReached(node, startState, endState, outPath);
                return SOLVED;

            } else {
                // We have not reached the goal - add the neighbors.
                var costs :Vector.<Number> = new Vector.<Number>();
                var neighbors :Vector.<PathNode> = new Vector.<PathNode>();

                getNodeNeighbors(node, costs, neighbors);

                for (var ii :int = 0; ii < neighbors.length; ++ii) {
                    if ( costs[ii] == Number.MAX_VALUE ) {
                        continue;
                    }

                    var newCost:Number = node.costFromStart + costs[ii];

                    var inOpen:PathNode   = neighbors[ii].inOpen ? neighbors[ii] : null;
                    var inClosed:PathNode = neighbors[ii].inClosed ? neighbors[ii] : null;
                    var inEither:PathNode = inOpen ? inOpen : inClosed;

                    //trace( "neighbor", neighbors[i].state, "inOpen", inOpen, "inClosed", inClosed );

                    if (inEither) {
                        // Is this node is in use, and the cost is not an improvement,
                        // continue on.
                        if (inEither.costFromStart <= newCost) {
                            continue;    // Do nothing. This path is not better than existing.
                        }

                        // Groovy. We have new information or improved information.
                        inEither.parent = node;
                        inEither.costFromStart = newCost;
                        inEither.estToGoal = _graph.leastCostEstimate( inEither.state, endState );
                    }

                    if (inClosed) {
                        // now open
                        inClosed.inClosed = false;
                        inClosed.inOpen = true;
                        open.push(inClosed);
                    }

                    if (!inEither) {
                        var pNode :PathNode = neighbors[ii];
                        pNode.parent = node;
                        pNode.costFromStart = newCost;
                        pNode.estToGoal = _graph.leastCostEstimate(pNode.state, endState),
                            pNode.inOpen = true;
                        open.push( pNode );
                    }
                }
                open.sort(compareTotalCost);
            }
            node.inClosed = true;
        }

        return NO_SOLUTION;
    }

    internal function goalReached (node :PathNode, start :int, end :int, path :Vector.<int> = null) :Vector.<int> {
        // We have reached the goal.
        // How long is the path? Used to allocate the vector which is returned.
        var count :int = 1;
        var it :PathNode = node;
        while (it.parent) {
            ++count;
            it = it.parent;
        }

        if (path == null) {
            path = new Vector.<int>(count);
        } else {
            path.length = count;
        }
        path[0] = start;
        path[count-1] = end;
        count -= 2;

        it = node.parent;
        while (it.parent) {
            path[count] = it.state;
            it = it.parent;
            --count;
        }

        return path;
    }

    internal function getNodeNeighbors (node :PathNode, costs :Vector.<Number>, pathNodes :Vector.<PathNode>) :void {
        var states :Vector.<int> = new Vector.<int>();
        _graph.adjacentCost(node.state, states, costs);

        for (var ii:int=0; ii<states.length; ++ii) {
            if (states[ii] in _pathNodePool) {
                pathNodes[ii] = _pathNodePool[states[ii]];
            } else {
                var pn :PathNode = new PathNode(_frame, states[ii], Number.MAX_VALUE, Number.MAX_VALUE, null);
                _pathNodePool[states[ii]] = pn;
                pathNodes[ii] = pn;
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

    protected var _frame :int;
    protected var _graph :IGraph;

    private var _pathNodePool :Dictionary;
}
};
