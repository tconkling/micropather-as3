//
// aciv

package micropather {

public interface IGraph
{
    function leastCostEstimate (stateStart :int, stateEnd :int) :Number;
    function adjacentCost (node :int, states :Vector.<int>, costs :Vector.<Number>) :void;
}

};
