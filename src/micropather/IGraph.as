//
// aciv

package micropather {

public interface IGraph
{
    /** @return the estimated least cost of a path between the two given states */
    function leastCostEstimate (stateStart :int, stateEnd :int) :Number;

    /**
     * Fill outStates and outCosts with the neighbors of the given node,
     * and the costs to move to those neighbors.
     */
    function adjacentCost (node :int, outStates :Vector.<int>, outCosts :Vector.<Number>) :void;
}

};
