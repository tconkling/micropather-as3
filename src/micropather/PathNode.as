//
// aciv

package micropather {

internal class PathNode
{
    public var state :int;               // the client state
    public var costFromStart :Number;    // exact
    public var estToGoal :Number;        // estimated
    public var parent :PathNode;         // the parent is used to reconstruct the path

    public var next :PathNode;
    public var prev :PathNode;
    public var inOpen :Boolean;
    public var inClosed :Boolean;

    public function PathNode (state :int, costFromStart :Number, estToGoal :Number,
        parent :PathNode) {
        this.state = state;
        this.costFromStart = costFromStart;
        this.estToGoal = estToGoal;
        this.parent = parent;
    }

    public function get totalCost () :Number {
        return (this.costFromStart < Number.MAX_VALUE && this.estToGoal < Number.MAX_VALUE ?
            this.costFromStart + this.estToGoal :
            Number.MAX_VALUE);
    }
}
};
