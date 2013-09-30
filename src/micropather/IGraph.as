//
// aciv

package micropather {

public interface IGraph
{
    /** @return the estimated least cost of a path between the two given states */
    function leastCostEstimate (stateStart :Object, stateEnd :Object) :Number;

    /**
     * Fill outNeighborStates and outCosts with the neighbors of the given state,
     * and the costs to move to those neighbors.
     */
    function adjacentCost (state :Object, outNeighborStates :Vector.<Object>, outCosts :Vector.<Number>) :void;
}

};
