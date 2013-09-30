//
// micropather

package micropather {

import flash.utils.Dictionary;

public class MicroPather
{
    public function MicroPather (graph :IGraph) {
        _graph = graph;
    }

    public function solve (startState :Object, endState :Object, outPath :Vector.<Object> = null) :PathResult {
        if (startState == endState) {
            return START_END_SAME;
        }

        _pathNodePool = new Dictionary();

        OPEN.push(new PathNode(startState, 0, _graph.leastCostEstimate(startState, endState), null));
        var result :PathResult = null;
        while (OPEN.length > 0) {
            var node:PathNode = OPEN.pop();

            if (node.state == endState) {
                result = PathResult.solved(goalReached(node, startState, endState, outPath));
                break;

            } else {
                // We have not reached the goal - add the neighbors.
                getNodeNeighbors(node, COSTS, NEIGHBORS);

                for (var ii :int = 0; ii < NEIGHBORS.length; ++ii) {
                    if (COSTS[ii] == Number.MAX_VALUE) {
                        continue;
                    }

                    var newCost:Number = node.costFromStart + COSTS[ii];

                    var inOpen:PathNode   = NEIGHBORS[ii].inOpen ? NEIGHBORS[ii] : null;
                    var inClosed:PathNode = NEIGHBORS[ii].inClosed ? NEIGHBORS[ii] : null;
                    var inEither:PathNode = inOpen ? inOpen : inClosed;

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
                        OPEN.push(inClosed);
                    }

                    if (!inEither) {
                        var pNode :PathNode = NEIGHBORS[ii];
                        pNode.parent = node;
                        pNode.costFromStart = newCost;
                        pNode.estToGoal = _graph.leastCostEstimate(pNode.state, endState),
                            pNode.inOpen = true;
                        OPEN.push( pNode );
                    }
                }

                node.inClosed = true;

                OPEN.sort(compareTotalCost);

                // cleanup loop temporaries
                COSTS.length = 0;
                NEIGHBORS.length = 0;
            }

        }   // while (OPEN.length > 0)

        // cleanup function temporaries
        OPEN.length = 0;
        _pathNodePool = null;

        return (result || NO_SOLUTION);
    }

    protected function goalReached (node :PathNode, start :Object, end :Object, outPath :Vector.<Object> = null) :Vector.<Object> {
        // We have reached the goal.
        // How long is the path? Used to allocate the vector which is returned.
        var count :int = 1;
        var it :PathNode = node;
        while (it.parent) {
            ++count;
            it = it.parent;
        }

        if (outPath == null) {
            outPath = new Vector.<Object>(count);
        } else {
            outPath.length = count;
        }

        outPath[0] = start;
        outPath[count-1] = end;
        count -= 2;

        it = node.parent;
        while (it.parent) {
            outPath[count] = it.state;
            it = it.parent;
            --count;
        }

        return outPath;
    }

    protected function getNodeNeighbors (node :PathNode, costs :Vector.<Number>, pathNodes :Vector.<PathNode>) :void {
        _graph.adjacentCost(node.state, STATES, costs);

        for (var ii:int=0; ii<STATES.length; ++ii) {
            if (STATES[ii] in _pathNodePool) {
                pathNodes[ii] = _pathNodePool[STATES[ii]];
            } else {
                var pn :PathNode = new PathNode(STATES[ii], Number.MAX_VALUE, Number.MAX_VALUE, null);
                _pathNodePool[STATES[ii]] = pn;
                pathNodes[ii] = pn;
            }
        }

        // reset our scratch object
        STATES.length = 0;
    }

    protected function compareTotalCost (x :PathNode, y :PathNode) :Number {
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
    protected var _pathNodePool :Dictionary;

    /** scratch objects */
    protected static const STATES :Vector.<Object> = new <Object>[];
    protected static const COSTS :Vector.<Number> = new <Number>[];
    protected static const NEIGHBORS :Vector.<PathNode> = new <PathNode>[];
    protected static const OPEN :Vector.<PathNode> = new <PathNode>[];

    protected static const NO_SOLUTION :PathResult = PathResult.noSolution();
    protected static const START_END_SAME :PathResult = PathResult.startEndSame();
}
};
